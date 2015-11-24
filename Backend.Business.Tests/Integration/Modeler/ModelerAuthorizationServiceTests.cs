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
            const string email = "j.kowalski@zasoby.pl";
            const string password = "1Qazwsxedc";

            var sut = new ModelerAuthorizationService();

            //When
            var result = sut.Authorize(email, password);

            //Then
            result.Should().Be.True();
        }

        [TestMethod]
        public void GivenExistingUserWithIncorrectPassword_WhenAuthorizeMethodIsBeingCalled_ThenReturnsFalse()
        {
            //Given
            const string userName = "j.kowalski@zasoby.pl";
            const string password = "WRONG_PASSWORD";

            var sut = new ModelerAuthorizationService();

            //When
            var result = sut.Authorize(userName, password);

            //Then
            result.Should().Be.False();
        }
    }
}
