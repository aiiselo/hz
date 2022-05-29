import SwiftUI
import Firebase
import FirebaseAuth


struct LogInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailColor = Color("inactiveTextField")
    @State private var passwordColor = Color("inactiveTextField")
    @State private var showingFeedScreen = false
    
    @State var showResendLinkButton: Bool = false
    @Environment(\.presentationMode) var presentation
    @State private var errorLog = ""
    @State private var showingEmailAlert = false
    @State private var showingPasswordAlert = false
    @EnvironmentObject var vm: AppViewModel
    
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
                    HStack {
                        Spacer()
                        Button(action: {resetPassword() }) {
                            Text("Forgot password?")
                        }
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color("inactiveTextField"))
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 14))
                        .alert(isPresented:$showingPasswordAlert) {
                            Alert(title: Text("Success"), message: Text("Reset link has been send on your email"), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    Button("LOG IN") {
                        authUser(email: email, password: password)
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
                    
                    
                    NavigationLink(destination: FeedView(), isActive: $showingFeedScreen) {
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    
                    Text(errorLog)
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(Color.orange)
                        .multilineTextAlignment(.center)
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    
                    if showResendLinkButton {
                        Button(action: {resendLink() }) {
                            Text("Resend email confirmation link").underline()
                        }
                        .font(.custom("GillSans", size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
//                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                        .alert(isPresented:$showingEmailAlert) {
                            Alert(title: Text("Success"), message: Text("Verification link has been sent"), dismissButton: .default(Text("OK")))
                                                }
                    }
                    
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
    
    func authUser(email: String, password: String) {
        emailColor = Color("inactiveTextField")
        passwordColor = Color("inactiveTextField")
        let result = checkValidFields(email: email, password: password)
        if result == nil {
            Auth.auth().signIn(withEmail: email, password: password) {
            (result, error) in
                if error != nil {
                    errorLog = error!.localizedDescription
                }
                else {
                    
                    if Auth.auth().currentUser!.isEmailVerified {
                        showingFeedScreen = true
                    } else {
                        errorLog = "Account email is not verified"
                        showResendLinkButton = true
                    }
                }
                DispatchQueue.main.async {
                    vm.signedIn = true
                }
            }
        }
    }
    
    func checkValidFields(email: String, password: String) -> Int? {
        if email == "" || password == "" {
            errorLog = "Please, fill in all fields"
            if email == "" {
                emailColor = Color.orange
            }
            if password == "" {
                passwordColor = Color.orange
            }
            return 0
        } else {
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
    
    func resendLink() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if let error = error {errorLog = "Please try again"} else {
                    showingEmailAlert = true
            }
        })
    }
    
    func resetPassword() {
        passwordColor = Color("inactiveTextField")
        emailColor = Color("inactiveTextField")
        Auth.auth().sendPasswordReset(withEmail: email) {  (error) in
            if email == "" {
                errorLog = "Please fill in email"
                emailColor = .orange
            } else if let error = error {
                errorLog = "Please try again"
            } else {
                showingPasswordAlert = true
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
