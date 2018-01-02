require 'sinatra'

post '/VoterConfirmationRequest' do
  request.body.rewind
  json = JSON.parse request.body.read
  
  Post.create!(request: json, endpoint: "VoterConfirmationRequest")
  is_error = json["LastName"] == "Error"
  if !is_error
    {
      "VoterId" => "123456789",
      "IsRegisteredVoter" => json["FirstName"] == "Voter",
      "TransactionTimestamp" => Time.now.iso8601,
      "HasDMVSignature" => !json["DriversLicenseNo"].blank?
    }.to_json
  else
   {}.to_json 
  end
end
# Request:
# LastName
# FirstName
# MiddleName
# SSN9
# DOBYear (4)
# DOBDay (2)
# DOBMonth (2)
# DriversLicenseNo
# LocalityName
# Format (=JSON)

# Respsonse
# VoterID (9)
# IsRegisteredVoter (bool)
# If true, voter is a registered voter match. Protected voters will not return a match and will be required to register by paper method.
# TransactionTimestamp (datetime) Date formatted to use the ISO 8601 format with the UTC offset.
# HasDMVSignature (bool)  Confirmation that user has DMV signature. Must send Driver’s license number to return this value. Not needed for voter confirmations only.

post '/VoterRegistrationSubmission' do
  request.body.rewind
  json = JSON.parse request.body.read
  
  Post.create!(request: json, endpoint: "VoterRegistrationSubmission")
  is_error = json["LastName"] == "Error"
  if !is_error
    {}.to_json
  else
    {}.to_json
  end
end

  # Response:
  # VoterID
  # string
  # 9
  # Voter Identification number will be null if IsRegisteredVoter is false.
  # 2
  # IsRegisteredVoter
  # bool
  # Yes
  # If true, voter is a registered voter match. Protected voters will not return a match and will be required to register by paper method.
  # 3
  # TransactionTimestamp
  # datetime
  # 40
  # Yes
  #
  # Date formatted to use the ISO 8601 format with the UTC offset.
  # 4
  # HasDMVSignature
  #
  # Confirmation that user has DMV signature. Must send Driver’s license number to return this value. Not needed for voter confirmations only.


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end