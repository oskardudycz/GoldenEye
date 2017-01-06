function TaskDetailViewModel() {
    var self = this;
    self.Id = ko.observable();

    self.Name = ko.observable();
    self.Date = ko.observable();
    self.Description = ko.observable();
    self.Progress = ko.observable();

    function fill(data) {
        ko.ext.updateViewModel(self, data);
    }

    self.init = function (id) {
        taskService.getTask(id, fill);
    }

}