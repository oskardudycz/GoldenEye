function TaskDetailViewModel() {
    var self = this;
    self.Id = ko.observable();

    self.TaskName = ko.observable();
    self.Number = ko.observable();
    self.Date = ko.observable();
    self.Type = ko.observable();
    self.IsInternal = ko.observable();
    self.Amount = ko.observable();
    self.Time = ko.observable();
    self.StartDate = ko.observable();
    self.PlanDate = ko.observable();
    self.EndDate = ko.observable();
    self.Description = ko.observable();
    self.Color = ko.observable();
    self.Progress = ko.observable();

    function fill(data) {
        ko.ext.updateViewModel(self, data);
    }

    self.init = function (id) {
        service.getTask(id, fill);
    }

}