var TaskListViewModel = function (tasklist) {

    var self = this;
    self.tasklist = ko.observableArray(tasklist);

    self.init = function () {
        taskService.loadList(self.tasklist);
    }
};