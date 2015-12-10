using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Repository;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SharpTestsEx;

namespace Backend.Business.Tests.Integration.Modeler
{
    [TestClass]
    public class ModelerAuthorizationServiceTests
    {
        [Ignore]
        [TestMethod]
        public void GivenExistingUserWithCorrectPassword_WhenAuthorizeMethodIsBeingCalled_ThenReturnsTrue()
        {
            //Given
            const string email = "SampleAdmina";
            const string password = "1Qazwsxedc";

            using (var db = new SampleContext())
            {
                var sut = new UserRepository(db);

                //When
                var result = sut.Authorize(email, password);

                //Then
                result.Should().Be.True();
            }
        }

        [Ignore]
        [TestMethod]
        public void GivenExistingUserWithIncorrectPassword_WhenAuthorizeMethodIsBeingCalled_ThenReturnsFalse()
        {
            //Given
            const string userName = "SampleAdmina";
            const string password = "WRONG_PASSWORD";

            using (var db = new SampleContext())
            {
                var sut = new UserRepository(db);

                //When
                var result = sut.Authorize(userName, password);

                //Then
                result.Should().Be.False();
            }
        }
    }
}
