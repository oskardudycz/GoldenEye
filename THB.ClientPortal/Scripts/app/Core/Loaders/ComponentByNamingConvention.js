// Register it
ko.components.loaders.unshift((function () {
    var componentsPrefix = "Scripts/app/Components/";

    ////////////////////////////////////////////////////////
    ///                     PRIVATE                      ///   
    ////////////////////////////////////////////////////////

    function getViewPathFromComponentName(name) {
        return name + "/" + name + "View.html";
    }

    function getViewModelPathFromComponentName(name) {
        return name + "/" + name + "ViewModel.js";
    }

    function shouldUseNamingConventionForView(viewConfig) {
        return !viewConfig.element;
    }

    function shouldUseNamingConventionForViewModel(viewModelConfig) {
        return viewModelConfig.fromUrl;
    }

    function callDefaultBehaviour(callback) {
        callback(null);
    }

    function loadViewFromUrl(options) {
        var fullUrl = componentsPrefix + options.relativeUrl + "?cacheAge=" + (options.maxCacheAge || 1234);
        $.get(fullUrl, function (markupString) {
            ko.components.defaultLoader.loadTemplate(options.name, markupString, options.callback);
        }).fail(function () {
            callDefaultBehaviour(callback);
        });
    }

    function loadViewModelFromUrl(options) {
        var fullUrl = componentsPrefix + options.relativeUrl;

        $.cachedScript(fullUrl).done(function () {
            var viewModelConstructor = window[options.viewModelName];
            ko.components.defaultLoader.loadViewModel(options.name, viewModelConstructor, options.callback);
        }).fail(function () {
            callDefaultBehaviour(options.callback);
        });
    }

    ////////////////////////////////////////////////////////
    ///                     PUBLIC                       ///   
    ////////////////////////////////////////////////////////

    function getConfig(name, callback) {
        if (name.indexOf("-nc") === -1) {
            callDefaultBehaviour(callback);
            return;
        }

        var nameWithoutNc = name.replace("-nc", "");
        var capitalizedName = nameWithoutNc.charAt(0).toUpperCase() + nameWithoutNc.slice(1);

        //provide configuration for how to load the template/widget
        callback({
            template: { fromUrl: getViewPathFromComponentName(capitalizedName), name: capitalizedName + "View" },
            viewModel: { fromUrl: getViewModelPathFromComponentName(capitalizedName), name: capitalizedName + "ViewModel" }
        });
    }

    function loadViewModel(name, viewModelConfig, callback) {
        if (!shouldUseNamingConventionForViewModel(viewModelConfig)) {
            callDefaultBehaviour(callback);
            return;
        }

        var url = viewModelConfig.fromUrl || getViewPathFromComponentName(name);

        loadViewModelFromUrl({
            name: name,
            relativeUrl: url,
            maxCacheAge: viewModelConfig.maxCacheAge,
            callback: callback,
            viewModelName: viewModelConfig.name
        });
    }

    function loadTemplate(name, templateConfig, callback) {
        if (!shouldUseNamingConventionForView(templateConfig)) {
            callDefaultBehaviour(callback);
            return;
        }

        var url = templateConfig.fromUrl || getViewPathFromComponentName(name);

        loadViewFromUrl({
            name: name,
            relativeUrl: url,
            maxCacheAge: templateConfig.maxCacheAge,
            callback: callback,
            viewName: templateConfig.name
        });
    }

    return {
        getConfig: getConfig,
        loadTemplate: loadTemplate,
        loadViewModel: loadViewModel
    };
})());