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
                        .foregroundColor(.black)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundColor(.black)
                            Text("From: \(post.from)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.black)
                        }
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundColor(.black)
                            Text("To: \(post.to)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.black)
                        }
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.black)
                            Text("\(formattedDate)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.black)
                        }
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.black)
                            Text("Room: \(post.spotsLeft)")
                                .font(.custom("Avenir", size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    VStack {
                        Text(String(format: "$%.2f", post.currentSplit))
                            .foregroundColor(.black)
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
    @State private var startDate = Date()
    @State private var startTime = Date()
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
                    
                        .padding(.trailing, 4) // Add space after the image
                    
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
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Start Location", text: $startLocation)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        TextField("End Location", text: $endLocation)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            VStack {
                                Image(systemName: "calendar.badge.clock.rtl")
                                    .padding(.bottom, 2) // Add space below the image
                                DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date)
                            }
                            .frame(maxWidth: 100) // Limit width
                            Spacer().frame(width: 12) // Add space between the elements
                            VStack {
                                Image(systemName: "clock.fill")
                                DatePicker("", selection: $startTime, in: Date()..., displayedComponents: .hourAndMinute)
                            }
                            .frame(maxWidth: 100) // Limit width
                            Spacer().frame(width: 12) // Add space between the elements
                            VStack {
                                
                                Image(systemName: "dollarsign.arrow.circlepath")

                                TextField("Enter Cost", text: $cost)
                                    .keyboardType(.decimalPad)
                                    .padding(8) // Reduced padding to decrease size
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: 100) // Limit width
                        }
                        .padding(.horizontal, 8)
                        
                        // Apply Filters button
                        Button(action: fetchFilteredPosts) {
                            Text("Apply Filters")
                            font(.footnote) // Smaller font size
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 6)
                    .padding(.leading,4)
                    .padding([.horizontal, .top], 6)
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
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .offset(y: -100)
                    .padding(.trailing, 20)
                    .opacity(posts.isEmpty ? 0 : 1)
//                }
//                .padding(.trailing, 10)
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .offset(y: -16)
//                .opacity(posts.isEmpty ? 0 : 1)
            
            }
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
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
    
    private func fetchFilteredPosts() {
        firestoreManager.filterSearch(startLocation: startLocation, endLocation: endLocation, startDate: startDate, startTime: startTime, cost: Double(cost) ?? 0.0) { (postIDs, error) in
            if let error = error {
                print("Error filtering posts: \(error.localizedDescription)")
                return
            }
            
            guard let postIDs = postIDs else {
                print("No matching posts found")
                return
            }
            
            // Filter the posts array based on the returned list of post IDs
            let filteredPosts = self.posts.filter { postIDs.contains($0.id) }
            self.posts = filteredPosts
        }
    }
}

#Preview {
    RidesView()
}
