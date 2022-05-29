import SwiftUI
import FirebaseAuth
import FirebaseStorage
import Firebase


struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var passwordRepeat = ""
    @State private var emailColor = Color("inactiveTextField")
    @State private var passwordColor = Color("inactiveTextField")
    @State private var passwordRepeatColor = Color("inactiveTextField")
    @State private var errorLog = ""
    @State private var showingLandingScreen = false
    @State var showAlert: Bool = false
    @State private var showingAlert = false
    
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationView {
            ZStack{
                Color("backgroundColor").ignoresSafeArea()
                VStack {
                    Text("BOOK CROSSING")
                        .font(.custom("Cochin-Bold", size: 36))
                        .shadow(color: .black, radius: 4, x: 2, y: 2)
                        .foregroundColor(Color.white)
                    
                    ZStack(alignment: .leading){
                        if email.isEmpty {
                            Text("Email")
                                .foregroundColor(Color("inactiveTextField"))
                        }
                        TextField("",text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding(.all)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(lineWidth: 2, antialiased: true)
                                .foregroundColor(emailColor)
                        )
                    .padding(.leading)
                    .padding(.trailing)
        
                    ZStack(alignment: .leading){
                        if password.isEmpty {
                            Text("Password")
                                .foregroundColor(Color("inactiveTextField"))
                        }
                        SecureField("",text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding(.all)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(lineWidth: 2, antialiased: true)
                                .foregroundColor(passwordColor)
                        )
                    .padding(.leading)
                    .padding(.trailing)
                    
                    ZStack(alignment: .leading){
                        if passwordRepeat.isEmpty {
                            Text("Repeat password")
                                .foregroundColor(Color("inactiveTextField"))
                        }
                        SecureField("",text: $passwordRepeat)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding(.all)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(lineWidth: 2, antialiased: true)
                                .foregroundColor(passwordRepeatColor)
                        )
                    .padding(.leading)
                    .padding(.trailing)
                    
                    Button("SIGN UP") {
                        
                        self.showingAlert = registerUser(email: email, passFirst: password, passSecond: passwordRepeat)
                    }
                    .font(.custom("GillSans", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.all)
                    .background(Color("buttonColor"))
                    .cornerRadius(6)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    .alert(isPresented:$showingAlert) {
                        Alert(title: Text("Need verification"), message: Text("Verify email and log in"), dismissButton: .default(Text("Continue")){
                                                    self.showingLandingScreen = true
                                                })
                                            }

                    NavigationLink(destination: LandingView(), isActive: $showingLandingScreen) {
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    Text(errorLog)
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.orange)
                        .multilineTextAlignment(.center)
                    
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 80, trailing: 10))
            }
            .accentColor(Color.black)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
               ToolbarItem (placement: .navigation)  {
                  Image(systemName: "arrow.left")
                  .foregroundColor(.white)
                  .onTapGesture {
                      // code to dismiss the view
                      self.presentation.wrappedValue.dismiss()
                  }
               }
            })
        }.navigationBarHidden(true)
    }
    
    func checkValidFields(email: String, firstPassword: String, secondPassword: String) -> Int? {
        if email == "" {
            emailColor = Color.orange
        if firstPassword == "" {
                passwordColor = Color.orange
            }
            if secondPassword == ""{
                passwordRepeatColor = Color.orange
            }
            errorLog = "Please, fill in all the fields"
            return 0
        }
        else if firstPassword != secondPassword {
                errorLog = "Passwords don't match"
                passwordColor = Color.orange
                passwordRepeatColor = Color.orange
                return 0
        }
        else if firstPassword.count < 8 {
                    errorLog = "Passwords must be longer"
                    passwordColor = Color.orange
                    passwordRepeatColor = Color.orange
                    return 0
        }
        else {
            var returnValue = true
            let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
            
            do {
                let regex = try NSRegularExpression(pattern: emailRegEx)
                let nsString = email as NSString
                let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
                
                if results.count == 0
                {
                    errorLog = "Invalid email"
                    emailColor = Color.orange
                    return 0
                }
                
            } catch let error as NSError {
                errorLog = "Invalid email"
                emailColor = Color.orange
                return 0
            }
            
            return  nil
        }
          
    }
    
    func registerUser(email: String, passFirst: String, passSecond: String) -> Bool {
        emailColor = Color("inactiveTextField")
        passwordColor = Color("inactiveTextField")
        passwordRepeatColor = Color("inactiveTextField")
        
        let result = checkValidFields(email: email, firstPassword: passFirst, secondPassword: passSecond)
                
        if result == nil {
            Auth.auth().createUser(withEmail: email, password: passFirst) {
                (result, error) in
                if error != nil {
                    errorLog = error!.localizedDescription
                }
                
            }
            sleep(2)
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                if let error = error {errorLog = "Please try again"} else {
                }
                
            })
            
            createDB(idUser: Auth.auth().currentUser?.uid)
            
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
            }
            
            return true
            
        }
        else {return false}
    }
    
}

func createDB (idUser: String?) {
    if let uid = idUser {
        let letters = "0123456789"
        let userID = "user" + String((0..<10).map{ _ in letters.randomElement()! })
        let values = [
            "email": Auth.auth().currentUser?.email,
            "uid": uid,
            "username": userID,
            "country": "—",
            "books_num": "0",
            "exchanges_num": "0",
            "full_name": "",
            "bio": "",
            "link": "",
            "profileImageURL": ""
        ]
        Firestore.firestore().collection("users").document(uid).setData(values) { err in
            if let err = err {
                print(err)
                return
            }

            print("Success")
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

