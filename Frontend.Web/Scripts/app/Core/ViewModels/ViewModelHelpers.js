ko.ext = ko.ext || {};

ko.ext.updateViewModel = function(viewModel, model) {
    for (var prop in model) {
        if (model.hasOwnProperty(prop))
            if (viewModel[prop] && $.isFunction(viewModel[prop]))
                viewModel[prop](model[prop]);
    }
}