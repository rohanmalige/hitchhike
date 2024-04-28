//
//  RidesView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct RoundedPostView: View {
    let post: Post
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .overlay(
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 8)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Image(systemName: "mappin")
                            Text("From: \(post.from)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.primary)
                        }
                        HStack {
                            Image(systemName: "mappin")
                            Text("To: \(post.to)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.primary)
                        }
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(formattedDate)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.primary)
                        }
                        HStack {
                            Image(systemName: "person.2")
                            Text("Room: \(post.spotsLeft)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    VStack {
                        Text(String(format: "$%.2f", post.desiredSplit))
                            .foregroundColor(.primary)
                        Spacer()
                        
                    }
                }
                .padding()
            )
            .padding()
//            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 160)
            .shadow(radius: 5)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, HH:mm"
        let pickupDate = post.pickupDate.dateValue()
        return formatter.string(from: pickupDate)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search by destination", text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

struct RidesView: View {
    @ObservedObject private var firestoreManager = FirestoreManager()
    @State private var posts: [Post] = []
    @State private var searchDestination = ""
    @State private var isCreatingPost = false
    @State private var navigateToCreateView = false
    @State private var selectedPost: String?
    @State private var isShowingPostInfo = false
    
    @State private var selectedPostId: String?
    
    // filter properties
    @State private var isSearchExpanded = false
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var startLocationRadius = 10 // Default radius value
    @State private var endLocationRadius = 10 // Default radius value
    @State private var cost = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
//                Text("Rides")
//                    .font(.custom("Avenir-Heavy", size: 24))
////                    .padding(.top, 4)
//                    .padding(.bottom, 2)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                    
                    TextField("Search by destination", text: $searchDestination)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            // Expand the search options when tapped
                            // You can implement this functionality here
                            withAnimation {
                                isSearchExpanded.toggle()
                            }
                            
                        }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                
                if isSearchExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Start Location", text: $startLocation)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        TextField("End Location", text: $endLocation)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            Text("Start")
                            Picker("", selection: $startLocationRadius) {
                                ForEach(1..<10) { radius in
                                    Text("\(radius)")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Text("End")
                            Picker("", selection: $endLocationRadius) {
                                ForEach(1..<10) { radius in
                                    Text("\(radius)")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Text("Cost")
                            TextField("Enter Cost", text: $cost)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                        }
                        
                        // Apply Filters button
                        Button(action: filterSearch) {
                            Text("Apply Filters")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                        }
                        .padding(.top, 10)
                    }
                }
                
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(posts, id: \.id) { post in
                            NavigationLink(destination: PostInfoPopover(postId: post.id)) {
                                RoundedPostView(post: post)
                                    .padding(.vertical, 4)
                            }
//                            RoundedPostView(post: post)
//                                .onTapGesture {
//                                    selectedPostId = post.id
//                                    isShowingPostInfo = true
//                                    print(selectedPostId)
//                                    print(isShowingPostInfo)
//                                }
//                                .background(NavigationLink(destination: PostInfoPopover(postId: selectedPostId ?? ""),            isActive: .constant(false), label: EmptyView.init
//                                ))
                        }
                        Color.clear.frame(height: 100)
                    }
                }
                .sheet(isPresented: $isShowingPostInfo) {
                    if let selectedPostId = selectedPostId {
                        PostInfoPopover(postId: selectedPostId)
                    }
                }
                
                Button(action: {
                    navigateToCreateView = true
                }) {
                        Image(systemName: "pencil")
                        Text("Post")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .offset(y: -80)
                    .padding(.trailing, 20)
                    .opacity(posts.isEmpty ? 0 : 1)
//                }
//                .padding(.trailing, 10)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .offset(y: -16)
//                .opacity(posts.isEmpty ? 0 : 1)
            
            }
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                fetchPosts()
                print("number \(posts.count)")
            }
            .popover(isPresented: $isShowingPostInfo, content: {
                if let selectedPost = selectedPost {
                    PostInfoPopover(postId: selectedPost)
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(
            NavigationLink(
                destination: CreatePostView(),
                isActive: $navigateToCreateView,
                label: {
                    CreatePostView()
                }
            )
        )
    }
    
    private func fetchPosts() {
        firestoreManager.fetchPosts { fetchedPosts, error in
            print("fetching")
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
            }
            
            if let fetchedPosts = fetchedPosts {
                posts = fetchedPosts
                print("number of posts \(posts.count)")
                print("number of fposts \(fetchedPosts.count)")
            }
        }
    }
    
    private func filterSearch() {
        // call Firestore function
    }
}

#Preview {
    RidesView()
}
