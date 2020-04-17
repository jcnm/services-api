import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ routerPrime: Router) throws {
  // Basic "It works" example
  /// MARK - WEBSITE ROUTES
  /****************************** WEB SECTION **************************
   **
   **
   **
   *******************************************************************/

  
  let webController             = WebsiteController()
  let webUserController         = WebsiteUserController()
  let webDashboardController    = WebsiteDashboardController()
  let webServiceController      = WebsiteServiceController()
  let webOrganizationController = WebsiteOrganizationController()
  let webScheduleController     = WebsiteScheduleController()
  try routerPrime.register(collection: webController)
  try routerPrime.register(collection: webUserController)
  try routerPrime.register(collection: webDashboardController)
  try routerPrime.register(collection: webServiceController)
  try routerPrime.register(collection: webOrganizationController)
  try routerPrime.register(collection: webScheduleController)

  /// MARK - API ROUTES
  /**************************** API SECTION ****************************
   **
   **
   **
   *******************************************************************/
  

  let apiRouter           = routerPrime.grouped("api")
  let versionController   = VersionController()
  let userController      = UserController()
  try apiRouter.register(collection: userController)
  try apiRouter.register(collection: versionController)

  /**
   ** Logged User  activity Sector - 2
   */
  let sectorController = SectorController()
  try apiRouter.register(collection: sectorController)
  
  // bearer / token auth protected routes
  let bearer = apiRouter.grouped(User.tokenAuthMiddleware())

   /**
   ** Logged User  activity Industry - 3
   */
  let industryController = IndustryController()
  bearer.get(kIndustriesBasePath, use: industryController.list)
  bearer.post(kIndustriesBasePath, use: industryController.create)
  bearer.get(kIndustriesBasePath, Industry.parameter, use: industryController.show)
  bearer.patch(kIndustriesBasePath, Industry.parameter, use: industryController.update)
  bearer.patch(kIndustriesBasePath, Industry.parameter, kSectorRelativePath, use: industryController.sectorOfIndustry)

  /**
   ** Logged User  activity Organization - 4
   */
  let organizationController = OrganizationController()
  bearer.get(kOrganizationsBasePath, use: organizationController.list)
  bearer.post(kOrganizationsBasePath, use: organizationController.create)
  bearer.get(kOrganizationsBasePath, Organization.parameter, use: organizationController.show)
  bearer.patch(kOrganizationsBasePath, Organization.parameter, use: organizationController.update)
  bearer.patch(kOrganizationsBasePath, Organization.parameter, kSectorRelativePath, use: organizationController.sectorOfOrganization)
  
  /**
   ** Logged User  activity Service - 5
   */
  let servicesController = ServiceController()
//  bearer.get(kServicesBasePath, use: servicesController.list)
//  bearer.post(kServicesBasePath, use: servicesController.create)
//  bearer.get(kServicesBasePath, Service.parameter, use: servicesController.show)
//  bearer.patch(kServicesBasePath, Service.parameter, use: servicesController.update)
  bearer.patch(kServicesBasePath, Service.parameter, kSectorRelativePath, use: servicesController.update)
//  bearer.patch(kServicesBasePath, Service.parameter, kIndustryRelativePath, use: servicesController.industryOfService)
  
  /**
   ** Logged User  activity Order - 6
   */
  let orderController = OrderController()
  try apiRouter.register(collection: orderController)

  /// User Picture CREATE, UPDATE, FETCH, DELETE
  //  bearer.get(kUserBasePath, User.parameter, "pp", use: userController.deleteProfilePicture)
  //  bearer.post(kUserBasePath, User.parameter, "pp", use: userController.deleteProfilePicture)
  //  bearer.patch(kUserBasePath, User.parameter, "pp", use: userController.deleteProfilePicture)
  //  bearer.delete(kUserBasePath, User.parameter, "pp", use: userController.deleteProfilePicture)
  
  
  /**
   ** Logged User  activity Schedule - 7
   */
  let scheduleController = ScheduleController()
  try apiRouter.register(collection: scheduleController)

  /*************************** ADMIN SECTION *************************
   ***
   ***
   ***
   *******************************************************************/
  
  
  /// - MARK - Administrative routes
  
  
  /** User admin end point api spec
   */
  
  // Should be on administrative section
  let adminGroup = bearer.grouped(kAdministrationBasePath)
  let userAdminGroup = adminGroup.grouped(kUsersBasePath)
  userAdminGroup.get(use: userController.list)
  userAdminGroup.patch(User.parameter, use: userController.updateUser)
  
  // Example of configuring a controller
  //    let todoController = TodoController()
  //    router.get("todos", use: todoController.index)
  //    router.post("todos", use: todoController.create)
  //    router.delete("todos", Todo.parameter, use: todoController.deletedAt)
}
