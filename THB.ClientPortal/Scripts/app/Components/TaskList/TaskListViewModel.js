var TaskListViewModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    self.init = function () {
        service.loadList(self.tasklist);
    }
};