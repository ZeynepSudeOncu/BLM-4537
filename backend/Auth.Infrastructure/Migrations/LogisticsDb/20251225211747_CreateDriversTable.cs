using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Auth.Infrastructure.Migrations.LogisticsDb
{
    /// <inheritdoc />
    public partial class CreateDriversTable : Migration
    {
        /// <inheritdoc />
       protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.CreateTable(
        name: "Drivers",
        columns: table => new
        {
            Id = table.Column<Guid>(type: "uuid", nullable: false),
            FullName = table.Column<string>(type: "text", nullable: false),
            License = table.Column<string>(type: "text", nullable: false),
            Phone = table.Column<string>(type: "text", nullable: false),
            Status = table.Column<string>(type: "text", nullable: false),
            TruckId = table.Column<Guid>(type: "uuid", nullable: true)
        },
        constraints: table =>
        {
            table.PrimaryKey("PK_Drivers", x => x.Id);
            table.ForeignKey(
                name: "FK_Drivers_Trucks_TruckId",
                column: x => x.TruckId,
                principalTable: "Trucks",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        });

    migrationBuilder.CreateIndex(
        name: "IX_Drivers_TruckId",
        table: "Drivers",
        column: "TruckId",
        unique: true);
}


        /// <inheritdoc />
       protected override void Down(MigrationBuilder migrationBuilder)
{
    migrationBuilder.DropTable(
        name: "Drivers");
}

    }
}
