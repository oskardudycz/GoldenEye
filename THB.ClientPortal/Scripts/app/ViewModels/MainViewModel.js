
function MainViewModel() {
    var self = this;

    app.mainViewModel = self;

    self.current = ko.observable();
    self.AddTaskViewModel = new AddTaskViewModel();
    self.TaskListViewModel = new TaskListViewModel();
}

ko.components.register("main", {
    viewModel: MainViewModel,
    template: { element: "main-view" }
});