using System;
using System.Linq;
using Backend.Business.Context;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SharpTestsEx;

namespace Backend.Business.Tests.Modeler
{
    [TestClass]
    public class SaveTaskTests
    {
        [TestMethod]
        public void GivenFilledTask_WhenSaveTaskMethodIsBeingCalled_ThenSavesProperlyAndReturnsSameTask()
        {
            using (var db = new ModelerContext())
            {
                using (db.BeginTransaction())
                {
                    //GIVEN
                    var customer = db.Customers.First();
                    var taskType = db.TaskTypes.First();

                    var task = new Task
                    {
                        Name = "test",
                        ModificationDate = DateTime.Now,
                        PlannedStartDate = DateTime.Now,
                        PlannedEndDate = DateTime.Now,
                        PlanningDate = DateTime.Now,
                        Number = "123",
                        Date = DateTime.Now,
                        Description = "test",
                        Color = 123,
                        CustomerColor = 234,
                        Amount = 3,
                        IsInternal = false,
                        PlannedTime = 3,

                        CustomerId = customer.Id,
                        TypeId = taskType.Id
                    };

                    //WHEN
                    var result = db.SaveTask(task);
                   
                    //THEN
                    result.Should().Be.GreaterThan(0);


                    var taskFromDB = db.Tasks.Find(result);
                }
            }
        }
    }
}
