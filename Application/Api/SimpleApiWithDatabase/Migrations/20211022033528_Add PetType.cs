using Microsoft.EntityFrameworkCore.Migrations;

namespace SimpleApiWithDatabase.Migrations
{
    public partial class AddPetType : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PetType",
                table: "Pets",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PetType",
                table: "Pets");
        }
    }
}
