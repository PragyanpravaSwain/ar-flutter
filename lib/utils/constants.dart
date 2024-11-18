
const String baseUrl = 'http://192.168.12.196:3000/api';
const String loginEndpoint = '$baseUrl/auth/login';
const String permissionsEndpoint = '$baseUrl/permission/my';
const String registerEndpoint = "$baseUrl/users/register"; // Adjust as necessary
const String uploadAvtar = "$baseUrl/users/upload-avatar"; // Adjust as necessary
const String getMe = "$baseUrl/users/me"; // Adjust as necessary
const String addressEndpoint = "$baseUrl/address";
const String addSkillsEndpoint = "$baseUrl/skills/skills";
const String resumeSkillsEndpoint = "$baseUrl/skills/resume";
const String getSkillsEndpoint = "$baseUrl/skills";


const String emailRegex = r'^[^@]+@[^@]+\.[^@]+';

// Error messages
const String loginFailedMessage = 'Login failed. Please try again.';
const String fetchPermissionsFailedMessage = 'Failed to fetch permissions.';

