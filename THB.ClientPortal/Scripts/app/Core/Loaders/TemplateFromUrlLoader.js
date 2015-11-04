
var templateFromUrlLoader = (function () {
    var componentsPrefix = "Scripts/app/Components/";

    function getTemplatePathFromNamingConvention(templateName) {
        return name + "/" + templateName + "View.html";
    }

    function shouldUseNamingConvention(templateConfig) {
        return !templateConfig.element;
    }

    function loadTemplateFromUrl(options) {
        var fullUrl = componentsPrefix + options.relativeUrl + "?cacheAge=" + (options.maxCacheAge || 1234);
        $.get(fullUrl, function (markupString) {
            // We need an array of DOM nodes, not a string.
            // We can use the default loader to convert to the
            // required format.
            ko.components.defaultLoader.loadTemplate(options.name, markupString, options.callback);
        }).fail(function () {
            options.callback(null); // or whatever
        });
    }

    function loadTemplate(name, templateConfig, callback) {
        if (!shouldUseNamingConvention(templateConfig)) {
            callback(null);
            return;
        }

        var url = templateConfig.fromUrl || getTemplatePathFromNamingConvention(name);

        loadTemplateFromUrl({
            name: name,
            relativeUrl: url,
            maxCacheAge: templateConfig.maxCacheAge,
            callback: callback
        });
    }
    
    return {
        getConfig: function (name, callback) {
            if (name.indexOf("-nc") === -1) {
                callback(null);
                return;
            }

            
        },
        loadTemplate: loadTemplate
    };
})();

// Register it
ko.components.loaders.unshift(templateFromUrlLoader);