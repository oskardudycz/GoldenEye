var TaskListViewModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    service.loadList(self.tasklist);

    self.save = function (form) {
        ko.utils.postJson($("form")[0], self.tasklist);
    };

    self.viewModelName = "Zlecenia";
    self.viewName = "Zlecenia";
};