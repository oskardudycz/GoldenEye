var TaskListModel = function (tasklist) {
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