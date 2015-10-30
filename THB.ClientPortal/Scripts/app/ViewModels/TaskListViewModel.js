var TaskListViewModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    /*
    self.loadTaskList = function () {
        $.getJSON("https://localhost:44300/api/task", function (data) {
            var tasks = ko.mapping.fromJS(data);
            self.tasklist(tasks());
        });
    }
    */

    service.loadList(self.tasklist);

    self.save = function (form) {
        ko.utils.postJson($("form")[0], self.tasklist);
    };

    self.viewModelName = "Zlecenia";
    self.viewName = "Zlecenia";
};

ko.components.register("tasks-list", {
    viewModel: TaskListViewModel,
    template: { element: "Zlecenia" }
});