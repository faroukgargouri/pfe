namespace TrikiApi.Models
{
    public class Client
    {
        public int Id { get; set; }
        public string? CodeClient { get; set; }
        public string? RaisonSociale { get; set; }
        public string? Telephone { get; set; }
        public string? Ville { get; set; }

        public int UserId { get; set; }
        public User? User { get; set; }
    }
}
