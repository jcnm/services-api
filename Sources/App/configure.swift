import Authentication
import FluentPostgreSQL
import Vapor
import Leaf
import Paginator

let kDefaultPerPageFrontEndPagination = 10
let kDefaultPageFrontEndPagination = 1
/// Called before your application initializes.
let kDatabaseIdentifier: DatabaseIdentifier<AdoptedDatabase> = DatabaseIdentifier<AdoptedDatabase>.psql //.sqlite
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
  try services.register(AuthenticationProvider())
  try services.register(LeafProvider())
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)
  // Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  
  // Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  middlewares.use(SessionsMiddleware.self)
  services.register(middlewares)
  
  config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
  
  let paginationConf = OffsetPaginatorConfig(perPage: kDefaultPerPageFrontEndPagination,
      defaultPage: kDefaultPageFrontEndPagination )
  services.register(paginationConf)
  services.register { _ -> LeafTagConfig in
      var tags = LeafTagConfig.default()
    tags.use(OffsetPaginatorTag(templatePath: "offsetpaginator"), as: "offsetPaginator")
      return tags }
  // Configure a SQLite database
//  let sqlite = try SQLiteDatabase(storage: .file(path: "services.db"))
  // Configure a PostgreSQL database

  let postgreSQLConfig : PostgreSQLDatabaseConfig
  if !Config.Static.dbPsgURL.isEmpty {
    postgreSQLConfig = PostgreSQLDatabaseConfig(url: Config.Static.dbPsgURL, transport: .unverifiedTLS)!
  } else {
    postgreSQLConfig = PostgreSQLDatabaseConfig(hostname: Config.Static.dbPsgHostname, port: Config.Static.dbPsgPort, username: Config.Static.dbPsgUser, database: Config.Static.dbPsgBasename, password: Config.Static.dbPsgPassword, transport: PostgreSQLConnection.TransportConfig.cleartext)
  }
  let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)

  // Register the configured SQLite database to the database config.
  var databases = DatabasesConfig()
  databases.add(database: postgreSQL, as: kDatabaseIdentifier)
  databases.enableLogging(on: kDatabaseIdentifier)
  services.register(databases)
  
  // Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: Version.self, database: DatabaseIdentifier<Version.Database>.psql)
  migrations.add(model: Place.self, database: DatabaseIdentifier<Place.Database>.psql)
  migrations.add(model: Contact.self, database: DatabaseIdentifier<Contact.Database>.psql)
  migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
  migrations.add(model: UserToken.self, database: DatabaseIdentifier<UserToken.Database>.psql)
  migrations.add(model: Sector.self, database: DatabaseIdentifier<Sector.Database>.psql)
  migrations.add(model: Industry.self, database: DatabaseIdentifier<Industry.Database>.psql)
  migrations.add(model: Organization.self, database: DatabaseIdentifier<Organization.Database>.psql)
  migrations.add(model: Service.self, database: DatabaseIdentifier<Service.Database>.psql)
  migrations.add(model: UserOrganization.self, database: DatabaseIdentifier<UserOrganization.Database>.psql)
  migrations.add(model: Schedule.self, database: DatabaseIdentifier<Schedule.Database>.psql)
  migrations.add(model: Activity.self, database: DatabaseIdentifier<Activity.Database>.psql)
  migrations.add(model: Order.self, database:    DatabaseIdentifier<Order.Database>.psql)
  migrations.add(model: OrderItem.self, database:DatabaseIdentifier<OrderItem.Database>.psql)
  migrations.add(model: Contract.self, database: DatabaseIdentifier<Contract.Database>.psql)
  migrations.add(model: Currency.self, database: DatabaseIdentifier<Currency.Database>.psql)
  migrations.add(model: BankCard.self, database: DatabaseIdentifier<BankCard.Database>.psql)
  migrations.add(model: Payment.self, database:  DatabaseIdentifier<Payment.Database>.psql)
  migrations.add(model: Asset.self, database: DatabaseIdentifier<Asset.Database>.psql)
  migrations.add(model: ServiceAsset.self, database: DatabaseIdentifier<ServiceAsset.Database>.psql)
  migrations.add(model: Score.self, database: DatabaseIdentifier<Score.Database>.psql)
//  migrations.add(model: ServiceScore.self, database: kDatabaseIdentifier)

  migrations.add(migration: SeedVersion.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedPlace.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingContact.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedContact.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingUser.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedUser.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedSector.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedIndustry.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingOrganization.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedOrganization.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingUserOrganization.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedUserOrganization.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingService.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedService.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedSchedule.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedActivity.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedOrder.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedOrderItem.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedContract.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedCurrency.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedBankCard.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedPayment.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedAsset.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedServiceAsset.self, database: kDatabaseIdentifier)
  migrations.add(migration: ExistingScore.self, database: kDatabaseIdentifier)
  migrations.add(migration: SeedScore.self, database: kDatabaseIdentifier)
//  migrations.add(migration: SeedServiceScore.self, database: kDatabaseIdentifier)

  services.register(migrations)
}
