using Backend.Business.Context;
using Backend.Business.Repository;
using Backend.Business.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SharpTestsEx;

namespace Backend.Business.Tests.Integration.Modeler
{
    [TestClass]
    public class ModelerAuthorizationServiceTests
    {
        [TestMethod]
        public void GivenExistingUserWithCorrectPassword_WhenAuthorizeMethodIsBeingCalled_ThenReturnsTrue()
        {
            //Given
            const string email = "THBAdmina";
            const string password = "1Qazwsxedc";

            using (var db = new THBContext())
            {
                var sut = new ModelerUserRepository(db);

                //When
                var result = sut.Authorize(email, password);

                //Then
                result.Should().Be.True();
            }
        }

        [TestMethod]
        public void GivenExistingUserWithIncorrectPassword_WhenAuthorizeMethodIsBeingCalled_ThenReturnsFalse()
        {
            //Given
            const string userName = "THBAdmina";
            const string password = "WRONG_PASSWORD";

            using (var db = new THBContext())
            {
                var sut = new ModelerUserRepository(db);

                //When
                var result = sut.Authorize(userName, password);

                //Then
                result.Should().Be.False();
            }
        }
    }
}
