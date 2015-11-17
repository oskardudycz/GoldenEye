var AddTaskViewModel = function () {
    var self = this;
    var currentDate = new Date();

    self.TaskName = ko.observable().extend({ required: true });
    self.Number = ko.observable().extend({
        required: true,
        number: true,
        min: 1
    });
    self.Date = ko.observable().extend({
        required: true,
        date: true
    });
   // self.Type = ko.observableArray(['Typ1', 'Typ2', 'Typ3'])
    self.IsInternal = ko.observable();
    self.Amount = ko.observable().extend({
        number: true,
        min: 1
    });
    self.Time = ko.observable();
    self.StartDate = ko.observable().extend({
        date: true,
        min: {
            params: currentDate,
            message: "Data musi być późniejsza od dzisiejszej."
        }
    });
    self.PlanDate = ko.observable().extend({ date: true });
    self.EndDate = ko.observable().extend({
        date: true,
        min: {
            params: self.StartDate,
            message: "Data zakończenia musi być późniejsza od daty rozpoczęcia."
        }
    });
    self.Description = ko.observable();
    self.Color = ko.observable();
    self.Progress = ko.observable();

    self.Id = ko.observable();

    self.currentView = ko.observable();
    self.views = ko.observableArray(["Zlecenia", "Dodaj"]);

    self.viewModelName = "Dodaj";
    self.viewName = "Dodaj";
}

AddTaskViewModel.prototype.addTask = function () {
    var self = this;
    service.addTask(self);
};