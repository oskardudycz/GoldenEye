var ViewModelLocator = (function () {
    var self = {};

    var bindings = [];

    self.Register = function (binding) {
        bindings.push(binding);
    }

    self.Get = function (path) {
        var binding = bindings.find(function (element) {
            return element.path != undefined && element.path == path;
        });

        if (binding == undefined)
            return undefined;

        return binding.viewModel();
    }

    return self;
})();

ViewModelLocator.Register({
    path: '/Home/Index',
    viewModel: function () {
        return new TaskListModel([
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ]);
    }
});

ViewModelLocator.Register({
    path: '/Home/Index/',
    viewModel: function () {
        return new TaskListModel([
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ]);
    }
})

ViewModelLocator.Register({
    path: '/#Zlecenia',
    viewModel: function () {
        return new TaskListModel([
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ]);
    }
})

ViewModelLocator.Register({
    path: '/#Dodaj',
    viewModel: function () {
        return new TaskViewModel();
    }
})

ViewModelLocator.Register({
    path: '/Home/Index#Dodaj',
    viewModel: function () {
        return new TaskViewModel();
    }
})