import SwiftUI

struct SubTaskItemView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: SubTaskObservable
    var onDelete: ((_ taskId: String) -> Void)
    @State private var offset = CGSize.zero
    @State var duringDelete = false
    @State var taskName: String = ""
    @State var taskCompleted: Bool = false
    var throttler = Throttler(minimumDelay: 0.25)
    
    func completeTask() {
        let completed = !self.taskCompleted
        self.taskCompleted = completed
        
        throttler.throttle {
            task.completed = completed
        }
    }
    
    func updateTaskName(newValue: String)
    {
        throttler.throttle {
            self.task.name = newValue
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
                        .offset(x: abs(self.offset.width) > 55 ? self.offset.width + 54 : 0)
                        .padding(.trailing, 10)
                }
                .frame(height: 29)
                .background(Color.red)
                .opacity(self.duringDelete ? 1 : 0)
                .cornerRadius(15)
                
                HStack(alignment: .center) {
                    if taskCompleted {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.medium))
                            .frame(width: 18, height: 18, alignment: .topLeading)
                            .onTapGesture(perform: self.completeTask)
                            .opacity(0.5)
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.medium))
                            .frame(width: 18, height: 18, alignment: .topLeading)
                            .onTapGesture(perform: self.completeTask)
                    }
                    
                    TextField("Task name", text: $taskName)
                        .font(Font.init(UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)))
                        .onChange(of: taskName, perform: self.updateTaskName)
                        .opacity(taskCompleted ? 0.5 : 1)
                }
                .frame(height: 30)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
                .offset(x: offset.width, y: 0)
                .opacity(2 - Double(abs(offset.width / 100)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width.isLessThanOrEqualTo(0) {
                                self.offset = gesture.translation
                                self.duringDelete = true
                            }
                        }

                        .onEnded { _ in
                            if abs(self.offset.width) > 85 {
                                self.onDelete(self.task.id)
                            } else {
                                self.offset = .zero
                                self.duringDelete = false
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                if self.taskName == "" {
                    self.taskName = self.task.name
                }
                
                self.taskCompleted = self.task.completed
            }
        }
    }
}
