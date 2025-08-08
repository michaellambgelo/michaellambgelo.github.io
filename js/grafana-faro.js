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
        : "https://michaellamb.dev/faro-proxy?app=blog", // Production proxy
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
    };
    // Append the Web Tracing script script tag to the HTML page
    document.head.appendChild(webTracingScript);
  };
  // Append the Web-SDK script script tag to the HTML page
  document.head.appendChild(webSdkScript);
})();
