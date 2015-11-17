using System;
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
                using (var tran = db.BeginTransaction())
                {
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
                        Color = 123
                    };

                    var result = db.SaveTask(task);
                    
                    result.Should().Be.True();

                    tran.Rollback();
                }
            }
        }
    }
}
