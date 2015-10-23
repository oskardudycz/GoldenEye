var TaskListModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    self.loadTaskList = function () {
        $.getJSON("https://localhost:44300/api/task", function (data) {
            var tasks = ko.mapping.fromJS(data);
            self.tasklist(tasks());
        });
    }

    self.loadTaskList();
    /*
    if (!tasklist)
        tasklist = [
            { name: "test", number: "1", date: "02.08.2015", progress: "50%" },
            { name: "another test", number: "2", date: "05.09.2015", progress: "100%" }
        ];
        */
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