(function () {
  // Check if we're in a local development environment
  const isLocalDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
  
  console.log('isLocalDev', isLocalDev);
  var webSdkScript = document.createElement("script");
  // fetch the latest version of the Web-SDK from the CDN
  webSdkScript.src =
    "https://unpkg.com/@grafana/faro-web-sdk@^1.4.0/dist/bundle/faro-web-sdk.iife.js";
  webSdkScript.onload = () => {
    // Configure Faro with different endpoints for production vs development
    const faroConfig = {
      // Use appropriate URL based on environment
      url: isLocalDev 
        ? "http://localhost:8787/faro-proxy?app=blog" // Local development proxy
        : "https://grafana.michaellamb.dev/faro-proxy?app=blog", // Production proxy
      app: {
        name: "blog",
        version: "1.0.0",
        environment: isLocalDev ? "development" : "production",
      }
    };
    
    console.log('Faro config (blog):', faroConfig);
    
    // Initialize Faro with the appropriate configuration
    window.GrafanaFaroWebSdk.initializeFaro(faroConfig);
    
    // Load instrumentations at the onLoad event of the web-SDK and after the above configuration.
    // This is important because we need to ensure that the Web-SDK has been loaded and initialized before we add further instruments!
    var webTracingScript = document.createElement("script");
    // fetch the latest version of the Web Tracing package from the CDN
    webTracingScript.src =
      "https://unpkg.com/@grafana/faro-web-tracing@^1.4.0/dist/bundle/faro-web-tracing.iife.js";
    
    // Initialize, configure (if necessary) and add the the new instrumentation to the already loaded and configured Web-SDK.
    webTracingScript.onload = () => {
      window.GrafanaFaroWebSdk.faro.instrumentations.add(
        new window.GrafanaFaroWebTracing.TracingInstrumentation()
      );
      
      // Add user journey tracking after all instrumentations are loaded
      initUserJourneyTracking();
    };
    
    // Append the Web Tracing script script tag to the HTML page
    document.head.appendChild(webTracingScript);
    
    // Function to initialize user journey tracking
    function initUserJourneyTracking() {
      // Get the Faro instance
      const faro = window.GrafanaFaroWebSdk.faro;
      
      // Track page view on initial load
      trackPageView();
      
      // Track page view on history changes (for SPA-like navigation if applicable)
      window.addEventListener('popstate', trackPageView);
      
      // Function to track page views
      function trackPageView() {
        // Get current page information
        const url = window.location.href;
        const path = window.location.pathname;
        const pageType = determinePageType(path);
        const pageTitle = document.title;
        
        // Push custom event for page view
        faro.api.pushEvent('page_view', {
          url: url,
          path: path,
          pageType: pageType,
          title: pageTitle,
          timestamp: new Date().toISOString()
        });
        
        console.log(`[Faro] Tracked page view: ${pageType} - ${pageTitle}`);
      }
      
      // Function to determine page type based on URL path
      function determinePageType(path) {
        if (path === '/' || path.match(/^\/page\d+\/?$/)) {
          return 'home';
        } else if (path === '/filter.html' || path.includes('/filter')) {
          return 'category';
        } else if (path.match(/^\/\d{4}\/\d{2}\/\d{2}\//)) {
          return 'article';
        } else {
          return 'other';
        }
      }
      
      // Track clicks on links to understand user navigation patterns
      document.addEventListener('click', function(e) {
        // Find closest anchor tag if the click was on a child element
        let target = e.target;
        while (target && target.tagName !== 'A') {
          target = target.parentElement;
        }
        
        // If we found an anchor tag
        if (target && target.tagName === 'A') {
          const href = target.getAttribute('href');
          if (href && !href.startsWith('javascript:') && !href.startsWith('#')) {
            // Determine link type
            let linkType = 'external';
            let destinationType = 'unknown';
            
            if (href.startsWith('/') || href.includes(window.location.hostname)) {
              linkType = 'internal';
              const path = href.startsWith('/') ? href : new URL(href).pathname;
              destinationType = determinePageType(path);
            }
            
            // Push custom event for link click
            faro.api.pushEvent('link_click', {
              linkType: linkType,
              destinationType: destinationType,
              href: href,
              linkText: target.textContent.trim(),
              fromPageType: determinePageType(window.location.pathname),
              timestamp: new Date().toISOString()
            });
            
            console.log(`[Faro] Tracked link click: ${linkType} to ${destinationType} - ${href}`);
          }
        }
      });
      
      // Track category filter interactions if on filter page
      if (window.location.pathname.includes('/filter')) {
        // Use MutationObserver to detect when the filter results change
        const filterResultsContainer = document.querySelector('.posts-list');
        if (filterResultsContainer) {
          const observer = new MutationObserver(function(mutations) {
            // When filter results change, track the event
            const activeFilters = Array.from(document.querySelectorAll('.tag-filter.active'))
              .map(el => el.textContent.trim());
              
            if (activeFilters.length > 0) {
              faro.api.pushEvent('category_filter', {
                filters: activeFilters,
                resultCount: document.querySelectorAll('.posts-list .post-title').length,
                timestamp: new Date().toISOString()
              });
              
              console.log(`[Faro] Tracked category filter: ${activeFilters.join(', ')}`);
            }
          });
          
          observer.observe(filterResultsContainer, { childList: true, subtree: true });
        }
      }
    }
  };
  // Append the Web-SDK script script tag to the HTML page
  document.head.appendChild(webSdkScript);
})();
