using System;
using Backend.Business.Context;
using Backend.Business.Entities;
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

            var task = new TaskEntity
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
                CustomerId = 1,
                CustomerColor = 234,
                Amount = 3,
                IsInternal = false,
                PlannedTime = 3,
                TypeId = 4
            };

            var userId = 1;

            //WHEN
            var result = serializer.Serialize(new TaskSaveRequest(userId, task));

            //THEN
            result.Should().Not.Be.Null();
        }
        
        [TestMethod]
        public void GivenXmlWithSaveResult_WhenDeserialized_ThenIdIsDeserializedProperly()
        {
            //Given
            var serializer = new TaskXmlSerializer();

            var xml =
                "<?xml version=\"1.0\" encoding=\"utf-8\"?><Response ResponseType=\"Units_Save\"><Result><Value><Ref Id=\"1\" EntityType=\"Unit\"/></Value></Result></Response>";

            //When
            var result = serializer.Deserialize(xml);

            //Then
            result.Should().Not.Be.Null();
            result.Result.Should().Not.Be.Null();
            result.Result.Value.Should().Not.Be.Null();
            result.Result.Value.Ref.Should().Not.Be.Null();
            result.Result.Value.Ref.Id.Should().Be.EqualTo(1);
        }

        [TestMethod]
        public void GivenXmlWithSaveResultWithError_WhenDeserialized_ThenErrorMessageIsDeserializedProperly()
        {
            //Given
            var serializer = new TaskXmlSerializer();

            const string errorMessage = "Some crazy exception appeared!";

            var xml =
                string.Format("<?xml version=\"1.0\" encoding=\"utf-8\"?><Response ResponseType=\"Units_Save\"><Result><Error ErrorMessage=\"{0}\"></Error></Result></Response>", errorMessage);

            //When
            var result = serializer.Deserialize(xml);

            //Then
            result.Should().Not.Be.Null();
            result.Result.Should().Not.Be.Null();
            result.Result.Error.Should().Not.Be.Null();
            result.Result.Error.ErrorMessage.Should().Be.EqualTo(errorMessage);
        }
    }
}
