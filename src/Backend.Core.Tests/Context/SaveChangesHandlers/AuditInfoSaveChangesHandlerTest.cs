using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Core.Context;
using System.Data.Entity;
using GoldenEye.Shared.Core.IOC;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Context.SaveChangesHandler.Base;
using Moq;
using System.Linq;
using GoldenEye.Frontend.Core.Web.Security;
using GoldenEye.Shared.Core.Security;

namespace GoldenEye.Backend.Core.Tests.Context.SaveChangesHandlers
{
    [TestClass]
    public class AuditInfoSaveChangesHandlerTest
    {
        private SampleContext _context;

        public AuditInfoSaveChangesHandlerTest()
        {

        }
        
        [TestMethod]
        public void GivenNewTask_WhenRunAuditHandle_ThenShouldAppendAuditInfo()
        {
            //GIVEN
            var task = new TaskEntity()
            {
                Amount = 1,
                Date = DateTime.Now,
                Description = "Test description",
                Name = "Test task name",
                Number = "Task1234",
                Progress = 5
            };
            var addedEntites = new List<TaskEntity>() {
                task
            };
            var updatedEntities = new List<TaskEntity>();

            var handler = new AuditInfoSaveChangesHandler();

            var userInfoProviderMock = new Mock<IUserInfoProvider>();

            userInfoProviderMock.Setup(m => m.GetCurrentUserId<int>())
                .Returns(2);

            //WHEN
            handler.Handle(addedEntites, updatedEntities, userInfoProviderMock.Object);
            
            //THEN
            var entity = addedEntites.First();
            Assert.AreEqual(entity.CreatedBy, 2);
            Assert.AreEqual(entity.LastModifiedBy, entity.CreatedBy);
        }
        [TestMethod]
        public void GivenUpdatedTask_WhenRunAuditHandle_ThenShouldUpdateAuditInfo()
        {
            //GIVEN
            var task = new TaskEntity()
            {
                Id = 2,
                Amount = 1,
                Date = DateTime.Now,
                Description = "Test description",
                Name = "Test task name",
                Number = "Task1234",
                Progress = 5,
                CreatedBy = 2,
                LastModifiedBy = 2,
                Created = DateTime.Parse("10/10/2010"),
                LastModified = DateTime.Parse("10/10/2010")
            };
            var addedEntites = new List<TaskEntity>();
            var updatedEntities = new List<TaskEntity>() {
                task
            };

            var handler = new AuditInfoSaveChangesHandler();

            var userInfoProviderMock = new Mock<IUserInfoProvider>();

            userInfoProviderMock.Setup(m => m.GetCurrentUserId<int>())
                .Returns(10);

            //WHEN
            handler.Handle(addedEntites, updatedEntities, userInfoProviderMock.Object);
            
            //THEN
            var entity = updatedEntities.First();
            Assert.AreEqual(entity.LastModifiedBy, 10);
            Assert.AreNotEqual(entity.CreatedBy, entity.LastModifiedBy);
            Assert.AreNotEqual(DateTime.Parse("10/10/2010"), entity.LastModified);
            Assert.AreEqual(DateTime.Parse("10/10/2010"), entity.Created);
        }
    }
}
