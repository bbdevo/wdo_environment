/**
 * Created by Peter Felegyi on 2023.06.19.
 */

public with sharing class avonniRelationshipGraph_Controller {

    public static List<User> allUsers = new List<User>();
    public static List<UserRole> allRoles = new List<UserRole>();

	public static String userId = USerInfo.getUserId();

	@AuraEnabled(cacheable=true)
    public static WrapperClass2 setParameters(){
		System.debug('userId: ' + userId); 
		WrapperClass2 usersbyRoleToSend = new WrapperClass2(); 
        WrapperClass usersByRoleId = new WrapperClass();

		try{
        allUsers = [SELECT Id, Name, UserRoleId, ManagerId, SmallPhotoUrl FROM User];
        System.debug('size: ' + allUsers.size());

        allRoles = [SELECT Id, Name, DeveloperName FROM UserRole];
        System.debug('allRoles: ' + allRoles);

        User currentUser = getUser(userId);
		String currentUserRoleName = getRoleName(currentUser.UserRoleId);
		String currentUserProfilePicture = getProfilePicURL(userId);
        User managerUser = getUser(currentUser.ManagerId);
		String managerUserRoleName = getRoleName(managerUser.UserRoleId);
		String managerUserProfilePicture = getProfilePicURL(currentUser.ManagerId);
        List<User> subUsers = getUsers(currentUser.Id);
		List<String> subUserRoleIds = new List<String>();
		List<String> subUsersProfilePictures = getProfilePicURLs(userId);
		System.debug('SUBUSERS: ' + subUsers.size());
		for (User u : subUsers) {
			subUserRoleIds.add(u.UserRoleId);
		}

		List<String> subUsersRoleNames = getRoleNames(subUserRoleIds);

        System.debug('currentuser: ' + currentuser);
        System.debug('currentUserRoleName: ' + currentUserRoleName);
        System.debug('managerUser: ' + managerUser);
        System.debug('managerUserRoleName: ' + managerUserRoleName);
        System.debug('subUsers: ' + subUsers);
		System.debug('subUsersRoleNames: ' + subUsersRoleNames);

		usersByRoleId.currentUser = currentUser;
		usersByRoleId.currentUserRoleName = currentUserRoleName;
		usersByRoleId.currentUserProfilePicture = currentUserProfilePicture;
		usersByRoleId.managerUser = managerUser;
		usersByRoleId.managerUserRoleName = managerUserRoleName;
		usersByRoleId.managerUserProfilePicture = managerUserProfilePicture;
		usersByRoleId.subUsers = subUsers;
		usersByRoleId.subUsersRoleNames = subUsersRoleNames;
		usersByRoleId.subUsersProfilePictures = subUsersProfilePictures;

		System.debug('usersByRoleId.currentUser: ' + usersByRoleId.currentUser);
        System.debug('usersByRoleId.currentUserRoleName: ' + usersByRoleId.currentUserRoleName);
        System.debug('usersByRoleId.managerUser: ' + usersByRoleId.managerUser);
        System.debug('usersByRoleId.managerUserRoleName: ' + usersByRoleId.managerUserRoleName);
        System.debug('usersByRoleId.subUsers: ' + usersByRoleId.subUsers);
		System.debug('usersByRoleId.subUsersRoleNames: ' + usersByRoleId.subUsersRoleNames);

		usersbyRoleToSend.label = 'Role Hierarchy';
		usersbyRoleToSend.name = 'role-hierarchy';
		usersbyRoleToSend.avatarSrc = 'https://www.lightningdesignsystem.com/assets/images/avatar3.jpg';
		usersbyRoleToSend.avatarFallbackIconName = 'standard:account';
		usersbyRoleToSend.href = 'https://ev1686048899255.lightning.force.com/lightning/r/Employee/' + currentuser.Id + '/view';
		usersbyRoleToSend.items = usersByRoleId;

		return usersbyRoleToSend;

		}catch(Exception ex){
			System.debug('userId: ' + userId);
			throw new AuraHandledException(ex.getMessage());
		}
    }    

    public static User getUser(String userId){
        User tempUser = new User();
        for (User user : allUsers) {
            if(user.Id == userId){
                tempUser = user;
            }
        }
        return tempUser;
    }

    public static List<User> getUsers(String userId){
        List<User> tempUser = new List<User>();
        for (User user : allUsers) {
            if(user.ManagerId != null && user.ManagerId == userId){
                tempUser.add(user);
            }
        }
        return tempUser;
    }

	public static String getRoleName(String userRoleId){
        String tempRoleName;
        for (UserRole userRole : allRoles) {
            if(userRole.Id == userRoleId){
                tempRoleName = userRole.Name;
            }
        }
        return tempRoleName;
    }

	public static List<String> getRoleNames(List<String> subUserRoleIds){
        List<String> tempRoleIds = new List<String>();
        for (UserRole userRole : allRoles) {
			for (String uid : subUserRoleIds) {
				if(uid == userRole.Id){
					tempRoleIds.add(userRole.Name);
				}
			}
        }
        return tempRoleIds;
    }

	public static String getProfilePicURL(String userId){
        String tempURL = null;
        for (User user : allUsers) {
            if(user.Id == userId){
                tempURL =  'https://ev1686048899255.my.site.com' + user.SmallPhotoUrl;
            }
        }
        return tempURL;
    }

	public static List<String> getProfilePicURLs(String userId){
        List<String> tempURLs = new List<String>();
        for (User user : allUsers) {
            if(user.ManagerId != null && user.ManagerId == userId){
                tempURLs.add('https://ev1686048899255.my.site.com' + user.SmallPhotoUrl);
            }
        }
        return tempURLs;
    }

	/**
	 * @description Wrapper class 
	 */
	public class WrapperClass {
		@AuraEnabled
		public User currentUser { get; set; }
		@AuraEnabled
		public String currentUserRoleName { get; set; }
		@AuraEnabled
		public String currentUserProfilePicture { get; set; }
		@AuraEnabled
		public User managerUser { get; set; }
		@AuraEnabled
		public String managerUserRoleName { get; set; }
		@AuraEnabled
		public String managerUserProfilePicture { get; set; }
		@AuraEnabled
		public List<User> subUsers { get; set; }
		@AuraEnabled
		public List<String> subUsersRoleNames { get; set; }
		@AuraEnabled
		public List<String> subUsersProfilePictures { get; set; }
	}

	/**
	 * @description Wrapper class 
	 */
	public class WrapperClass2 {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String avatarSrc { get; set; }
		@AuraEnabled
		public String avatarFallbackIconName { get; set; }
		@AuraEnabled
		public String href { get; set; }
		@AuraEnabled
		public WrapperClass items { get; set; }
	}
}