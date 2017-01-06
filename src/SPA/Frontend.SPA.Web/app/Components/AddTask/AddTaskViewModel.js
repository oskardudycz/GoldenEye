var currentDate = new Date();

var AddTaskViewModel = function () {
    var self = this;

    self.Name = ko.observable().extend({ required: true });
    self.Date = ko.observable().extend({
        required: true,
        date: true
    });
    self.Progress = ko.observable().extend({
        min: 0,
        max:100,
        required: true
    });
    self.Description = ko.observable();
    
    self.Id = ko.observable();
    
    self.addTask = function() {
        taskService.addTask(self, function (data) {
            window.location = "#zadania";
        });
    }
}