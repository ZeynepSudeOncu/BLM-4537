using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Auth.Infrastructure.Migrations.LogisticsDb
{
    public partial class FixDepotIdToUuid : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                ALTER TABLE "Depots"
                ALTER COLUMN "Id" TYPE uuid
                USING "Id"::uuid;
            """);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                ALTER TABLE "Depots"
                ALTER COLUMN "Id" TYPE varchar(36);
            """);
        }
    }
}
