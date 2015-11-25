var currentDate = new Date();

var AddTaskViewModel = function () {
    var self = this;

    self.Name = ko.observable().extend({ required: true });
    self.Number = ko.observable().extend({
        required: true
    });
    self.Date = ko.observable().extend({
        required: true,
        date: true
    });
    
    self.IsInternal = ko.observable();
    self.Amount = ko.observable().extend({
        number: true,
        min: 1
    });
    self.PlannedTime = ko.observable();
    self.PlanningDate = ko.observable().extend({ date: true });
    self.PlannedStartDate = ko.observable().extend({
        date: true
    });
    self.PlannedEndDate = ko.observable().extend({
        date: true,
        min: {
            params: self.PlannedStartDate,
            message: "Data zakończenia musi być późniejsza od daty rozpoczęcia."
        }
    });
    self.Description = ko.observable();
    self.Color = ko.observable();
    self.Progress = ko.observable().extend({
        min: 1,
        max: 100
    });

    self.Types = ko.observableArray();
    self.TypeId = ko.observable();

    self.Customers = ko.observableArray();
    self.CustomerId = ko.observable();

    self.Id = ko.observable();

    self.currentView = ko.observable();
    self.views = ko.observableArray(["Zlecenia", "Dodaj"]);

    self.viewModelName = "Dodaj";
    self.viewName = "Dodaj";

    self.init = function () {
        service.getTaskTypes(self.Types);
        service.getClients(self.Customers);
    }
}

AddTaskViewModel.prototype.addTask = function () {
    var self = this;
    service.addTask(self);
};