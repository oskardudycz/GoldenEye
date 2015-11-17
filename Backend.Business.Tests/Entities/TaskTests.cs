using System;
using Backend.Business.Context;
using Backend.Business.Utils.Serialization;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SharpTestsEx;

namespace Backend.Business.Tests.Entities
{
    [TestClass]
    public class TaskTests
    {
        [TestMethod]
        public void GivenFilledTaskObject_WhenSerialized_ThenIsSerializedProperly()
        {
            //GIVEN
            var serializer = new TaskXmlSerializer();

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

            var userId = 1;

            //WHEN
            var result = serializer.Serialize(new TaskSaveRequest(userId, task));

            result.Should().Not.Be.Null();
        }
    }
}
