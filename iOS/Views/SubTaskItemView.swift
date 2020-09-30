import SwiftUI

struct SubTaskItemView: View {
    @ObservedObject var task: SubTaskObservable
    @Binding var tasks: [SubTask]
    var onDelete: ((_ taskId: String) -> Void)
    @State private var offset = CGSize.zero
    var throttler = Throttler(minimumDelay: 0.25)
    
    func completeTask() {
        let taskIndex = tasks.firstIndex { $0.id == task.id }
        
        if task.completed {
            task.completed = false
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = false
            }
        } else {
            task.completed = true
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = true
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Text("Delete")
                        .font(.caption)
                        .foregroundColor(Color.white)
                        .padding(.trailing, 15)
                }
                .frame(height: 29)
                .background(Color.red)
                .cornerRadius(15)
                
                HStack(alignment: .center) {
                    if task.completed {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.medium))
                            .frame(width: 18, height: 18, alignment: .topLeading)
                            .onTapGesture {
                                self.completeTask()
                            }
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.medium))
                            .frame(width: 18, height: 18, alignment: .topLeading)
                            .onTapGesture {
                                self.completeTask()
                            }
                    }
                    
                    TextField("Task name", text: $task.name)
                        .onChange(of: task.name) { newValue in
                            throttler.throttle {
                                let taskIndex = self.tasks.firstIndex { $0.id == task.id }
                                self.tasks[taskIndex!].name = newValue
                            }
                        }
                }
                .frame(height: 30)
                .background(Color.white)
                .cornerRadius(15)
                .offset(x: offset.width, y: 0)
                .opacity(2 - Double(abs(offset.width / 75)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width.isLessThanOrEqualTo(0) {
                                self.offset = gesture.translation
                            }
                            
                            print(1 / abs(self.offset.width))
                        }

                        .onEnded { _ in
                            if abs(self.offset.width) > 100 {
                                self.onDelete(self.task.id)
                            } else {
                                self.offset = .zero
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
