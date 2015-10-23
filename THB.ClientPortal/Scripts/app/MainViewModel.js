
function MainViewModel() {
    var self = this;

    app.mainViewModel = self;

    self.current = ko.observable();
    self.AddTaskModel = new AddTaskModel();
    self.TaskListModel = new TaskListModel();
}

ko.components.register("main", {
    viewModel: MainViewModel,
    template: { element: "main-view" }
});