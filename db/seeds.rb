AdminUser.create!([
  {email: "sam@example.com", encrypted_password: "$2a$11$ATRcJPuNeKkXfqPhclNOAuPxrJJo5c259QYdJstBkEMCY.toN8Ou2", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 14, current_sign_in_at: "2016-11-12 17:21:11", last_sign_in_at: "2016-11-12 16:46:32", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", role_id: 2},
  {email: "don@example.com", encrypted_password: "$2a$11$jALlOCpqSK0U71/yUoFzk.l6JpO5ZCAVk0sD68MAWDAjk6SszisiC", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 3, current_sign_in_at: "2016-11-13 02:19:10", last_sign_in_at: "2016-11-12 17:11:51", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", role_id: 5},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 31, current_sign_in_at: "2016-11-13 10:47:31", last_sign_in_at: "2016-11-13 10:45:13", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", role_id: 1},
  {email: "bob@example.com", encrypted_password: "$2a$11$PF65wOrnmozdpGu4P8INlepYlghWPceE8sA.u2hbhTnCSNECMK3uO", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2016-11-12 17:15:46", last_sign_in_at: "2016-11-12 17:04:37", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", role_id: 3},
  {email: "ray@example.com", encrypted_password: "$2a$11$Q/RDL0EzUjC0wIFm6pCTW.wzhOIf8dBmfp.zGizpvVHGFkyciPkRS", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2016-11-12 17:17:03", last_sign_in_at: "2016-11-12 17:17:03", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", role_id: 4}
])
AdminUsersAudit.create!([
  {email: "sam@example.com", encrypted_password: "$2a$11$ATRcJPuNeKkXfqPhclNOAuPxrJJo5c259QYdJstBkEMCY.toN8Ou2", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 14, current_sign_in_at: "2016-11-12 17:21:11", last_sign_in_at: "2016-11-12 16:46:32", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 2, admin_user_id: 6},
  {email: "don@example.com", encrypted_password: "$2a$11$jALlOCpqSK0U71/yUoFzk.l6JpO5ZCAVk0sD68MAWDAjk6SszisiC", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 3, current_sign_in_at: "2016-11-13 02:19:10", last_sign_in_at: "2016-11-12 17:11:51", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 5, admin_user_id: 7},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 28, current_sign_in_at: "2016-11-13 07:44:28", last_sign_in_at: "2016-11-13 02:20:06", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "bob@example.com", encrypted_password: "$2a$11$PF65wOrnmozdpGu4P8INlepYlghWPceE8sA.u2hbhTnCSNECMK3uO", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2016-11-12 17:15:46", last_sign_in_at: "2016-11-12 17:04:37", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 3, admin_user_id: 8},
  {email: "ray@example.com", encrypted_password: "$2a$11$Q/RDL0EzUjC0wIFm6pCTW.wzhOIf8dBmfp.zGizpvVHGFkyciPkRS", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2016-11-12 17:17:03", last_sign_in_at: "2016-11-12 17:17:03", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 4, admin_user_id: 9},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 28, current_sign_in_at: "2016-11-13 07:44:28", last_sign_in_at: "2016-11-13 02:20:06", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 29, current_sign_in_at: "2016-11-13 10:34:23", last_sign_in_at: "2016-11-13 07:44:28", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 29, current_sign_in_at: "2016-11-13 10:34:23", last_sign_in_at: "2016-11-13 07:44:28", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 30, current_sign_in_at: "2016-11-13 10:45:13", last_sign_in_at: "2016-11-13 10:34:23", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 30, current_sign_in_at: "2016-11-13 10:45:13", last_sign_in_at: "2016-11-13 10:34:23", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1},
  {email: "admin@example.com", encrypted_password: "$2a$11$1I7ENczf9eRDfZ7xyLZsius4v2X4JxQvq7rvELroVlXKfitUW.31a", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 31, current_sign_in_at: "2016-11-13 10:47:31", last_sign_in_at: "2016-11-13 10:45:13", current_sign_in_ip: "127.0.0.1/32", last_sign_in_ip: "127.0.0.1/32", role_id: 1, admin_user_id: 1}
])
HolidayCalendar.create!([
  {name: "Diwali", as_on: "2016-10-31", description: "Diwali", comments: "", business_unit_id: 1},
  {name: "Christmas", as_on: "2016-12-25", description: "Christmas", comments: "", business_unit_id: 4},
  {name: "Bhai Duj", as_on: "2016-08-10", description: "Bhai Duj", comments: "", business_unit_id: 1},
  {name: "Easter", as_on: "2016-09-17", description: "Easter", comments: "", business_unit_id: 4}
])
Lookup.create!([
  {name: "CCI", description: "Cognitive Clouds India", rank: 3.0, comments: "", lookup_type_id: 2},
  {name: "CCS", description: "Cognitive Clouds Singapore", rank: 1.0, comments: "", lookup_type_id: 2},
  {name: "Engineering", description: "Engineering", rank: 1.0, comments: "", lookup_type_id: 3},
  {name: "Administration", description: "Administration", rank: 4.0, comments: "", lookup_type_id: 3},
  {name: "CEO", description: "CEO", rank: 1.0, comments: "", lookup_type_id: 8},
  {name: "COO", description: "COO", rank: 2.0, comments: "", lookup_type_id: 8},
  {name: "CFO", description: "CFO", rank: 3.0, comments: "", lookup_type_id: 8},
  {name: "CBO", description: "CBO", rank: 4.0, comments: "", lookup_type_id: 8},
  {name: "CPO", description: "CPO", rank: 5.0, comments: "", lookup_type_id: 8},
  {name: "PL", description: "Privileged Leave", rank: 1.0, comments: "", lookup_type_id: 10},
  {name: "CL", description: "Casual Leave", rank: 2.0, comments: "", lookup_type_id: 10},
  {name: "SL", description: "Sick Leave", rank: 3.0, comments: "", lookup_type_id: 10},
  {name: "UL", description: "Unpaid Leave", rank: 4.0, comments: "", lookup_type_id: 10},
  {name: "Sales Tax", description: "Sales Tax", rank: 3.0, comments: "", lookup_type_id: 11},
  {name: "Service Tax", description: "Service Tax", rank: 1.0, comments: "", lookup_type_id: 11},
  {name: "Value Added Tax", description: "Value Added Tax", rank: 2.0, comments: "", lookup_type_id: 11},
  {name: "Income Tax", description: "Income Tax", rank: 4.0, comments: "", lookup_type_id: 11},
  {name: "Finance", description: "Finance", rank: 6.0, comments: "", lookup_type_id: 3},
  {name: "Sales", description: "Sales", rank: 2.0, comments: "", lookup_type_id: 3},
  {name: "Rental", description: "Rental", rank: 1.0, comments: "", lookup_type_id: 12},
  {name: "Travel", description: "Travel", rank: 2.0, comments: "", lookup_type_id: 12},
  {name: "Hotel", description: "Hotel", rank: 3.0, comments: "", lookup_type_id: 12},
  {name: "Communication", description: "Communication", rank: 4.0, comments: "", lookup_type_id: 12},
  {name: "Food", description: "Food", rank: 5.0, comments: "", lookup_type_id: 12},
  {name: "Training", description: "Training", rank: 6.0, comments: "", lookup_type_id: 12},
  {name: "iOS", description: "iOS", rank: 1.0, comments: "", lookup_type_id: 13},
  {name: "Android", description: "Android", rank: 2.0, comments: "", lookup_type_id: 13},
  {name: "Java", description: "Java", rank: 3.0, comments: "", lookup_type_id: 13},
  {name: "Web", description: "Web", rank: 4.0, comments: "", lookup_type_id: 13},
  {name: "Legal", description: "Legal", rank: 5.0, comments: "", lookup_type_id: 3},
  {name: "Security", description: "Security", rank: 7.0, comments: "", lookup_type_id: 3},
  {name: "CCU", description: "Cognitive Clouds US", rank: 2.0, comments: "Test", lookup_type_id: 2},
  {name: "Sales", description: "Sales", rank: 5.0, comments: "", lookup_type_id: 13},
  {name: "Project Management", description: "Project Management", rank: 6.0, comments: "", lookup_type_id: 13},
  {name: "Finance", description: "Finance", rank: 7.0, comments: "", lookup_type_id: 13},
  {name: "Administration", description: "Administration", rank: 8.0, comments: "", lookup_type_id: 13},
  {name: "Management", description: "Management", rank: 9.0, comments: "", lookup_type_id: 13},
  {name: "HR", description: "HR", rank: 10.0, comments: "", lookup_type_id: 13},
  {name: "TnM", description: "Time and Material", rank: 2.0, comments: "", lookup_type_id: 14},
  {name: "FB", description: "Fixed Bid", rank: 1.0, comments: "", lookup_type_id: 14},
  {name: "INT", description: "Internal", rank: 3.0, comments: "", lookup_type_id: 14},
  {name: "DEF", description: "Default", rank: 4.0, comments: "", lookup_type_id: 14},
  {name: "New", description: "New", rank: 1.0, comments: "", lookup_type_id: 15},
  {name: "Discussion", description: "Discussion", rank: 2.0, comments: "", lookup_type_id: 15},
  {name: "Proposal", description: "Proposal", rank: 3.0, comments: "", lookup_type_id: 15},
  {name: "Signed", description: "Signed", rank: 4.0, comments: "", lookup_type_id: 15},
  {name: "Delivery", description: "Delivery", rank: 5.0, comments: "", lookup_type_id: 15},
  {name: "Lost", description: "Lost", rank: 6.0, comments: "", lookup_type_id: 15},
  {name: "Hold", description: "Hold", rank: 7.0, comments: "", lookup_type_id: 15},
  {name: "Canceled", description: "Canceled", rank: 8.0, comments: "", lookup_type_id: 15},
  {name: "New", description: "New", rank: 1.0, comments: "", lookup_type_id: 16},
  {name: "Delivery", description: "Delivery", rank: 2.0, comments: "", lookup_type_id: 16},
  {name: "Completed", description: "Completed", rank: 3.0, comments: "", lookup_type_id: 16},
  {name: "Hold", description: "Hold", rank: 4.0, comments: "", lookup_type_id: 16},
  {name: "Canceled", description: "Canceled", rank: 5.0, comments: "", lookup_type_id: 16},
  {name: "New", description: "New", rank: 1.0, comments: "", lookup_type_id: 17},
  {name: "Sent", description: "Sent", rank: 2.0, comments: "", lookup_type_id: 17},
  {name: "Paid", description: "Paid", rank: 3.0, comments: "", lookup_type_id: 17},
  {name: "Part-Paid", description: "Part-Paid", rank: 4.0, comments: "", lookup_type_id: 17},
  {name: "Canceled", description: "Canceled", rank: 5.0, comments: "", lookup_type_id: 17},
  {name: "Hold", description: "Hold", rank: 6.0, comments: "", lookup_type_id: 17},
  {name: "New", description: "New", rank: 1.0, comments: "", lookup_type_id: 18},
  {name: "Received", description: "Received", rank: 2.0, comments: "", lookup_type_id: 18},
  {name: "Reconciled", description: "Reconciled", rank: 3.0, comments: "", lookup_type_id: 18},
  {name: "Part-Reconciled", description: "Part-Reconciled", rank: 4.0, comments: "", lookup_type_id: 18},
  {name: "Canceled", description: "Canceled", rank: 5.0, comments: "", lookup_type_id: 18},
  {name: "Hold", description: "Hold", rank: 6.0, comments: "", lookup_type_id: 18}
])
LookupType.create!([
  {name: "Departments", description: "Departments", comments: ""},
  {name: "Designations", description: "Designations", comments: ""},
  {name: "Business Units", description: "Business Units", comments: ""},
  {name: "Vacation Codes", description: "Vacation Codes", comments: ""},
  {name: "Invoice Adder Types", description: "Invoice Adder Types", comments: ""},
  {name: "Cost Adder Types", description: "Cost Adder Types", comments: ""},
  {name: "Skills", description: "Skills", comments: ""},
  {name: "Project Types", description: "Project Types", comments: ""},
  {name: "Pipeline Statuses", description: "Pipeline Statuses", comments: ""},
  {name: "Project Statuses", description: "Project Statuses", comments: ""},
  {name: "Invoice Statuses", description: "Invoice Statuses", comments: ""},
  {name: "Payment Statuses", description: "Payment Statuses", comments: ""}
])
ProjectType.create!([
  {billed: true, comments: "", business_unit_id: 1, project_type_code_id: 97, description: "Time and Material"},
  {billed: true, comments: "", business_unit_id: 1, project_type_code_id: 96, description: "Fixed Bid"},
  {billed: true, comments: "", business_unit_id: 1, project_type_code_id: 98, description: "Internal"},
  {billed: true, comments: "", business_unit_id: 1, project_type_code_id: 99, description: "Default"},
  {billed: true, comments: "", business_unit_id: 4, project_type_code_id: 97, description: "Time and Material"},
  {billed: true, comments: "", business_unit_id: 4, project_type_code_id: 96, description: "Fixed Bid"}
])
Role.create!([
  {name: "Administrator", description: "Administrator", rank: 1.0, comments: "", super_admin: true, ancestry: nil, parent_name: nil},
  {name: "User", description: "User", rank: 2.0, comments: "", super_admin: false, ancestry: "1/5/4/3", parent_name: "Manager"},
  {name: "Manager", description: "Manager", rank: 3.0, comments: "", super_admin: false, ancestry: "1/5/4", parent_name: "Director"},
  {name: "Director", description: "Director", rank: 4.0, comments: "", super_admin: false, ancestry: "1/5", parent_name: "Executive"},
  {name: "Executive", description: "Executive", rank: 5.0, comments: "", super_admin: false, ancestry: "1", parent_name: "Administrator"},
  {name: "Lead", description: "Lead", rank: 7.0, comments: "", super_admin: false, ancestry: "1/5/4/3", parent_name: "Manager"},
  {name: "Consultant", description: "Consultant", rank: 8.0, comments: "", super_admin: false, ancestry: "1/5/4/3", parent_name: "Manager"}
])
VacationPolicy.create!([
  {description: "Privileged Leave", as_on: "2016-01-01", paid: true, days_allowed: 15.0, comments: "", business_unit_id: 1, vacation_code_id: 71},
  {description: "Unpaid Leave", as_on: "2016-01-01", paid: false, days_allowed: 365.0, comments: "", business_unit_id: 1, vacation_code_id: 74},
  {description: "Casual Leave", as_on: "2016-01-01", paid: true, days_allowed: 5.0, comments: "", business_unit_id: 1, vacation_code_id: 72},
  {description: "Sick Leave", as_on: "2016-01-01", paid: true, days_allowed: 3.0, comments: "", business_unit_id: 1, vacation_code_id: 73},
  {description: "Privileged Leave", as_on: "2016-01-01", paid: true, days_allowed: 10.0, comments: "", business_unit_id: 4, vacation_code_id: 71},
  {description: "Unpaid Leave", as_on: "2016-11-10", paid: false, days_allowed: 30.0, comments: "", business_unit_id: 4, vacation_code_id: 74}
])
BusinessUnit.create!([
  {name: "CCI", description: "Cognitive Clouds India", rank: 3.0, comments: "", lookup_type_id: 2},
  {name: "CCS", description: "Cognitive Clouds Singapore", rank: 1.0, comments: "", lookup_type_id: 2},
  {name: "CCU", description: "Cognitive Clouds US", rank: 2.0, comments: "Test", lookup_type_id: 2}
])
ProjectTypeCode.create!([
  {name: "TnM", description: "Time and Material", rank: 2.0, comments: "", lookup_type_id: 14},
  {name: "FB", description: "Fixed Bid", rank: 1.0, comments: "", lookup_type_id: 14},
  {name: "INT", description: "Internal", rank: 3.0, comments: "", lookup_type_id: 14},
  {name: "DEF", description: "Default", rank: 4.0, comments: "", lookup_type_id: 14}
])
VacationCode.create!([
  {name: "PL", description: "Privileged Leave", rank: 1.0, comments: "", lookup_type_id: 10},
  {name: "CL", description: "Casual Leave", rank: 2.0, comments: "", lookup_type_id: 10},
  {name: "SL", description: "Sick Leave", rank: 3.0, comments: "", lookup_type_id: 10},
  {name: "UL", description: "Unpaid Leave", rank: 4.0, comments: "", lookup_type_id: 10}
])
