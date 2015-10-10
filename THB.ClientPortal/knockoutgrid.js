var TaskListModel = function (tasklist) {
    if (!tasklist)
        tasklist = [
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ];

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    self.addTasks = function () {
        self.tasklist.push({
            name: "",
            number: "",
            date: "",
            progress: ""
        });
    };

    self.save = function (form) {
        ko.utils.postJson($("form")[0], self.tasklist);
    };

    self.viewModelName = "Zlecenia";
    self.viewName = "Zlecenia";
};



ko.components.register("tasks-list", {
    viewModel: TaskListModel,
    template: { element: "Zlecenia" }
});