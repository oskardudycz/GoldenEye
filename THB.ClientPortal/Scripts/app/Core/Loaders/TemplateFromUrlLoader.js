
var templateFromUrlLoader = (function () {
    var componentsPrefix = "Scripts/app/Components/";

    function getViewPathFromComponentName(name) {
        return name + "/" + name + "View.html";
    }

    function getViewModelPathFromComponentName(name) {
        return name + "/" + name + "ViewModel.js";
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

    function getConfig(name, callback) {
        if (name.indexOf("-nc") === -1) {
            callback(null);
            return;
        }

        var nameWithoutNc = name.replace("-nc", "");
        var capitalizedName = nameWithoutNc.charAt(0).toUpperCase() + nameWithoutNc.slice(1);

        //provide configuration for how to load the template/widget
        callback({
            viewModel: window[capitalizedName + "ViewModel"],
            template: { fromUrl: getViewPathFromComponentName(capitalizedName) }
        });

    }

    function loadTemplate(name, templateConfig, callback) {
        if (!shouldUseNamingConvention(templateConfig)) {
            callback(null);
            return;
        }

        var url = templateConfig.fromUrl || getViewPathFromComponentName(name);

        loadTemplateFromUrl({
            name: name,
            relativeUrl: url,
            maxCacheAge: templateConfig.maxCacheAge,
            callback: callback
        });
    }

    return {
        getConfig: getConfig,
        loadTemplate: loadTemplate
    };
})();

// Register it
ko.components.loaders.unshift(templateFromUrlLoader);