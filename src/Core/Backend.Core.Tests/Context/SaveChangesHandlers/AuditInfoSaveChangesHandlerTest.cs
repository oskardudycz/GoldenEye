using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using Moq;
using System.Linq;
using GoldenEye.Backend.Core.Context;
using GoldenEye.Shared.Core.Security;

namespace GoldenEye.Backend.Core.Tests.Context.SaveChangesHandlers
{
    [TestClass]
    public class AuditInfoSaveChangesHandlerTest
    {
        [Ignore]
        [TestMethod]
        public void GivenNewTask_WhenRunAuditHandle_ThenShouldAppendAuditInfo()
        {
            //GIVEN
            var task = new TaskEntity
            {
                Date = DateTime.Now,
                Name = "Test task name",
                Progress = 5
            };
            var addedEntites = new List<TaskEntity>
            {
                task
            };
            var updatedEntities = new List<TaskEntity>();

            var handler = new AuditInfoSaveChangesHandler();

            var userInfoProviderMock = new Mock<IUserInfo>();

            userInfoProviderMock.Setup(m => m.GetCurrentUserId<int>())
                .Returns(2);

            var dataContextMock = new Mock<IDataContext>();
            dataContextMock.Setup(el => el.GetAddedEntities())
                .Returns(addedEntites);

            dataContextMock.Setup(el => el.GetUpdatedEntities())
                .Returns(updatedEntities);

            //WHEN
            handler.Handle(dataContextMock.Object);
            
            //THEN
            var entity = addedEntites.First();
            Assert.AreEqual(entity.CreatedBy, 2);
            Assert.AreEqual(entity.LastModifiedBy, entity.CreatedBy);
        }
        [Ignore]
        [TestMethod]
        public void GivenUpdatedTask_WhenRunAuditHandle_ThenShouldUpdateAuditInfo()
        {
            //GIVEN
            var task = new TaskEntity()
            {
                Id = 2,
                Date = DateTime.Now,
                Name = "Test task name",
                Progress = 5,
                CreatedBy = 2,
                LastModifiedBy = 2,
                Created = DateTime.Parse("10/10/2010"),
                LastModified = DateTime.Parse("10/10/2010")
            };
            var addedEntites = new List<TaskEntity>();
            var updatedEntities = new List<TaskEntity>
            {
                task
            };

            var handler = new AuditInfoSaveChangesHandler();

            var userInfoProviderMock = new Mock<IUserInfo>();

            userInfoProviderMock.Setup(m => m.GetCurrentUserId<int>())
                .Returns(10);

            var dataContextMock = new Mock<IDataContext>();
            dataContextMock.Setup(el => el.GetAddedEntities())
                .Returns(addedEntites);

            dataContextMock.Setup(el => el.GetUpdatedEntities())
                .Returns(updatedEntities);

            //WHEN
            handler.Handle(dataContextMock.Object);
            
            //THEN
            var entity = updatedEntities.First();
            Assert.AreEqual(entity.LastModifiedBy, 10);
            Assert.AreNotEqual(entity.CreatedBy, entity.LastModifiedBy);
            Assert.AreNotEqual(DateTime.Parse("10/10/2010"), entity.LastModified);
            Assert.AreEqual(DateTime.Parse("10/10/2010"), entity.Created);
        }
    }
}
