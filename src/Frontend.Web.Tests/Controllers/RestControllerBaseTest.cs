using AutoMapper;
using GoldenEye.Backend.Business.Mappings;
using GoldenEye.Shared.Business.DTOs;
using GoldenEye.Shared.Core.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace GoldenEye.Frontend.Web.Tests.Controllers
{
    [TestClass]
    public class RestControllerBaseTest
    {
        //private static int size;
        [ClassInitialize]
        public static void MapperInit(TestContext context)
        {
            Mapper.AddProfile<MappingDefinition>();
        }
        [TestMethod]
        public void Get()
        {
            var service = new Mock<IRestService<TaskDTO>>();
            var dto = new Mock<TaskDTO>();
            //var repository = new Mock<ITaskRepository>();

            //var controller = new RestControllerBase(service.Object);
        }

        [TestMethod]
        public void Put()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }

        [TestMethod]
        public void Post()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }

        [TestMethod]
        public void Delete()
        {
            var service = new Mock<IRestService<TaskDTO>>();
        }
    }
}
