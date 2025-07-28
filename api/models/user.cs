using System.ComponentModel.DataAnnotations;

namespace TrikiApi.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required]
        public string FirstName { get; set; } = "";

        [Required]
        public string LastName { get; set; } = "";

        [Required]
        public string Email { get; set; } = "";

        [Required]
        public string PasswordHash { get; set; } = "";

        public string? CodeSage { get; set; }

        public string Role { get; set; } = "Représentant";

    }
}
