using Microsoft.AspNetCore.Mvc;
using TrikiApi.Data;
using TrikiApi.Dtos;
using TrikiApi.Models;

namespace TrikiApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly TrikiDbContext _context;

        public AuthController(TrikiDbContext context)
        {
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (_context.Users.Any(u => u.Email == dto.Email))
                return BadRequest(new { message = "Email déjà utilisé." });

            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password);

            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PasswordHash = hashedPassword,
                CodeSage = dto.CodeSage,
                Role = "Représentant"
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Inscription réussie" });
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginDto dto)
        {
            var user = _context.Users.FirstOrDefault(u => u.Email == dto.Email);

            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
                return Unauthorized(new { message = "Email ou mot de passe incorrect." });

            return Ok(new
            {
                id = user.Id, // ✅ utilisé dans Flutter
                firstName = user.FirstName,
                lastName = user.LastName,
                email = user.Email,
                codeSage = user.CodeSage,
                role = user.Role
            });
        }
    }
}
