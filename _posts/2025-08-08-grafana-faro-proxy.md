---

layout: post
title: "Using Cloudflare Workers to create a reverse proxy for Grafana Faro"
date: 2025-08-08
category: cloudflare
image: "/seo/2025-08-08.png"
published: true

---

As I alluded to in [my original post discussing Grafana Faro](/social/2025/06/18/grafana-faro.html), ad-blockers and anti-tracking software can prevent my website from correctly sending telemetry to Grafana. My strategy to get around this is to proxy all Grafana Faro requests through a Cloudflare Worker. I created a proxy server which uses Cloudflare Workers environment secrets to keep the Grafana ingest tokens secure, allowing me to scale this proxy server for multiple apps. 

Here is the basic design:

1. A frontend app is created in Grafana Faro with a unique ingest token
2. The ingest token is stored as an environment variable in the Cloudflare Worker `grafana-faro-proxy`
3. `grafana-faro-proxy` receives requests from the client with a query parameter to determine the source app (e.g., `?app=blog`)
4. The request/response to and from the Grafana collector endpoint are proxied between the client

To iterate on the Cloudflare Worker code, I opted to use [wrangler](https://developers.cloudflare.com/workers/wrangler/) to run the worker locally and test using this blog -- which I always run locally when writing blog posts **just like I am right now**.

I updated the `faroConfig` const used in the frontend to set up the client telemetry.

```js
const faroConfig = {
  // Use appropriate URL based on environment
  url: isLocalDev 
    ? "http://localhost:8787/faro-proxy?app=blog" // Local development proxy
    : "https://michaellamb.dev/faro-proxy?app=blog", // Production proxy
  app: {
    name: "blog",
    version: "1.0.0",
    environment: isLocalDev ? "development" : "production",
  }
```

# grafana-faro-proxy - [worker.js](https://github.com/michaellambgelo/grafana-faro-proxy/blob/main/worker.js)

The complete source code for the proxy server is below. You can find the latest version in the GitHub repository.

```js
/**
 * Cloudflare Worker for Grafana Faro RUM Data Proxy
 * Proxies requests from michaellamb.dev to Grafana Cloud
 */

// Default CORS headers with wildcard origin
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With, x-faro-session-id',
  'Access-Control-Max-Age': '86400',
};

// New function to generate proper CORS headers
function getCorsHeaders(request) {
  // Get the Origin header from the request
  const origin = request.headers.get('Origin');
  
  // If there's an origin header and it's from localhost or your domains, use it
  if (origin && (origin.includes('localhost') || 
                 origin.includes('michaellamb.dev'))) {
    return {
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With, x-faro-session-id',
      'Access-Control-Max-Age': '86400',
      'Vary': 'Origin', // Important when varying response based on Origin
    };
  }
  
  // Default CORS headers (wildcard)
  return CORS_HEADERS;
}

// Bot detection patterns
const BOT_USER_AGENTS = [
  'bot', 'crawler', 'spider', 'scraper', 'facebookexternalhit',
  'twitterbot', 'linkedinbot', 'whatsapp', 'telegram', 'slackbot',
  'googlebot', 'bingbot', 'yandexbot', 'duckduckbot', 'baiduspider'
];

function isBot(userAgent) {
  if (!userAgent) return false;
  const ua = userAgent.toLowerCase();
  return BOT_USER_AGENTS.some(pattern => ua.includes(pattern));
}

function isValidOrigin(origin, allowedOrigins) {
  if (!allowedOrigins) return true;
  const origins = allowedOrigins.split(',').map(o => o.trim());
  return origins.includes(origin) || origins.includes('*');
}

function getIngestTokenForApp(appName, env) {
  const tokenMap = {
    'blog': env.BLOG_INGEST_TOKEN,
    'letterboxd-viewer': env.LETTERBOXD_INGEST_TOKEN
  };
  
  return tokenMap[appName] || env.BLOG_INGEST_TOKEN; // default to blog token
}

function detectAppFromRequest(request) {
  const url = new URL(request.url);
  const referer = request.headers.get('Referer');
  
  // Method 1: Check for app parameter in query string
  const appParam = url.searchParams.get('app');
  if (appParam) {
    return appParam;
  }
  
  // Method 2: Detect from referer header
  if (referer) {
    if (referer.includes('/letterboxd-viewer/')) {
      return 'letterboxd-viewer';
    }
    // Default to blog for main site
    return 'blog';
  }
  
  // Method 3: Check custom header (if you want to add this to your frontend)
  const appHeader = request.headers.get('X-App-Name');
  if (appHeader) {
    return appHeader;
  }
  
  // Default to blog
  return 'blog';
}

async function handleFaroProxy(request, env) {
  // Get configuration from environment variables
  const collectorHost = env.GRAFANA_COLLECTOR_HOST || 'faro-collector-prod-us-east-0.grafana.net';
  const allowedOrigins = env.ALLOWED_ORIGINS;
  
  // Detect which app this request is from and get appropriate token
  const appName = detectAppFromRequest(request);
  const ingestToken = getIngestTokenForApp(appName, env);
  
  if (!ingestToken) {
    console.error(`No ingest token found for app: ${appName}`);
    return new Response('Configuration Error: No ingest token', { 
      status: 500,
      headers: getCorsHeaders(request) 
    });
  }
  
  const collectorPath = `/collect/${ingestToken}`;

  // Validate origin
  const origin = request.headers.get('Origin');
  if (allowedOrigins && !isValidOrigin(origin, allowedOrigins)) {
    return new Response('Forbidden: Invalid origin', { 
      status: 403,
      headers: getCorsHeaders(request) 
    });
  }

  // Bot detection
  const userAgent = request.headers.get('User-Agent');
  if (isBot(userAgent)) {
    console.log('Bot detected, blocking request:', userAgent);
    return new Response('Blocked: Bot detected', { 
      status: 403,
      headers: getCorsHeaders(request) 
    });
  }

  try {
    // Parse the incoming URL to get any additional path
    const url = new URL(request.url);
    const pathSuffix = url.pathname.replace('/faro-proxy', '');
    
    // Construct the target URL
    const targetUrl = `https://${collectorHost}${collectorPath}${pathSuffix}${url.search}`;
    
    // Clone the request to modify headers
    const modifiedRequest = new Request(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body,
    });

    // Add required headers
    modifiedRequest.headers.set('X-Forwarded-For', request.headers.get('CF-Connecting-IP') || request.headers.get('X-Forwarded-For') || '');
    modifiedRequest.headers.set('X-Forwarded-Proto', 'https');
    
    // Set Host header to the target host
    modifiedRequest.headers.set('Host', collectorHost);

    // Optional: Add custom data enrichment
    if (request.method === 'POST') {
      // You could modify the request body here to add custom fields
      // For now, we'll pass it through unchanged
    }

    // Make the request to Grafana
    const response = await fetch(modifiedRequest);
    
    // Create the response with CORS headers
    // First, get all the original headers except CORS headers
    const responseHeaders = Object.fromEntries(response.headers.entries());
    
    // Remove any existing CORS headers to prevent duplicates
    delete responseHeaders['access-control-allow-origin'];
    delete responseHeaders['access-control-allow-methods'];
    delete responseHeaders['access-control-allow-headers'];
    delete responseHeaders['access-control-max-age'];
    delete responseHeaders['vary'];
    
    // Create the response with our CORS headers
    const modifiedResponse = new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: {
        ...responseHeaders,
        ...getCorsHeaders(request),
      },
    });

    console.log(`Proxied request for app "${appName}": ${request.method} ${url.pathname} -> ${response.status}`);
    return modifiedResponse;

  } catch (error) {
    console.error('Proxy error:', error);
    return new Response('Internal Server Error', { 
      status: 500,
      headers: getCorsHeaders(request) 
    });
  }
}

async function handleRequest(request, env) {
  const url = new URL(request.url);
  
  // Handle CORS preflight requests
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: getCorsHeaders(request),
    });
  }

  // Route faro-proxy requests
  if (url.pathname.startsWith('/faro-proxy')) {
    return handleFaroProxy(request, env);
  }

  // For non-proxy requests, return 404
  return new Response('Not Found', { 
    status: 404,
    headers: getCorsHeaders(request) 
  });
}

// Cloudflare Workers entry point
export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env);
  },
};
```

## Testing and Conclusion

Seeing new data in both development and production environments means that the proxy is working!

![dashboard](/img/2025-08-08-faro-proxy-success.png)

Grafana Faro is an excellent and easy-to-setup solution for frontend observability but to benefit from RUM it is probably necessary to proxy the collector endpoint for best results. 

---

<blockquote class="text-post-media" data-text-post-permalink="https://www.threads.com/@themichaellamb/post/DNJQOX0RA08" data-text-post-version="0" id="ig-tp-DNJQOX0RA08" style=" background:#FFF; border-width: 1px; border-style: solid; border-color: #00000026; border-radius: 16px; max-width:540px; margin: 1px; min-width:270px; padding:0; width:99.375%; width:-webkit-calc(100% - 2px); width:calc(100% - 2px);"> <a href="https://www.threads.com/@themichaellamb/post/DNJQOX0RA08" style=" background:#FFFFFF; line-height:0; padding:0 0; text-align:center; text-decoration:none; width:100%; font-family: -apple-system, BlinkMacSystemFont, sans-serif;" target="_blank"> <div style=" padding: 40px; display: flex; flex-direction: column; align-items: center;"><div style=" display:block; height:32px; width:32px; padding-bottom:20px;"> <svg aria-label="Threads" height="32px" role="img" viewBox="0 0 192 192" width="32px" xmlns="http://www.w3.org/2000/svg"> <path d="M141.537 88.9883C140.71 88.5919 139.87 88.2104 139.019 87.8451C137.537 60.5382 122.616 44.905 97.5619 44.745C97.4484 44.7443 97.3355 44.7443 97.222 44.7443C82.2364 44.7443 69.7731 51.1409 62.102 62.7807L75.881 72.2328C81.6116 63.5383 90.6052 61.6848 97.2286 61.6848C97.3051 61.6848 97.3819 61.6848 97.4576 61.6855C105.707 61.7381 111.932 64.1366 115.961 68.814C118.893 72.2193 120.854 76.925 121.825 82.8638C114.511 81.6207 106.601 81.2385 98.145 81.7233C74.3247 83.0954 59.0111 96.9879 60.0396 116.292C60.5615 126.084 65.4397 134.508 73.775 140.011C80.8224 144.663 89.899 146.938 99.3323 146.423C111.79 145.74 121.563 140.987 128.381 132.296C133.559 125.696 136.834 117.143 138.28 106.366C144.217 109.949 148.617 114.664 151.047 120.332C155.179 129.967 155.42 145.8 142.501 158.708C131.182 170.016 117.576 174.908 97.0135 175.059C74.2042 174.89 56.9538 167.575 45.7381 153.317C35.2355 139.966 29.8077 120.682 29.6052 96C29.8077 71.3178 35.2355 52.0336 45.7381 38.6827C56.9538 24.4249 74.2039 17.11 97.0132 16.9405C119.988 17.1113 137.539 24.4614 149.184 38.788C154.894 45.8136 159.199 54.6488 162.037 64.9503L178.184 60.6422C174.744 47.9622 169.331 37.0357 161.965 27.974C147.036 9.60668 125.202 0.195148 97.0695 0H96.9569C68.8816 0.19447 47.2921 9.6418 32.7883 28.0793C19.8819 44.4864 13.2244 67.3157 13.0007 95.9325L13 96L13.0007 96.0675C13.2244 124.684 19.8819 147.514 32.7883 163.921C47.2921 182.358 68.8816 191.806 96.9569 192H97.0695C122.03 191.827 139.624 185.292 154.118 170.811C173.081 151.866 172.51 128.119 166.26 113.541C161.776 103.087 153.227 94.5962 141.537 88.9883ZM98.4405 129.507C88.0005 130.095 77.1544 125.409 76.6196 115.372C76.2232 107.93 81.9158 99.626 99.0812 98.6368C101.047 98.5234 102.976 98.468 104.871 98.468C111.106 98.468 116.939 99.0737 122.242 100.233C120.264 124.935 108.662 128.946 98.4405 129.507Z" /></svg></div><div style=" font-size: 15px; line-height: 21px; color: #000000; font-weight: 600; "> View on Threads</div></div></a></blockquote>
<script async src="https://www.threads.com/embed.js"></script>
