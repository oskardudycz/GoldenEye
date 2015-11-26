using Shared.Core.DTOs;

namespace Shared.Business.DTOs
{
    public class UserDTO : IDTO
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
    }
}