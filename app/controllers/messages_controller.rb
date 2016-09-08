class MessagesController < ApplicationController
  include ActionController::Live
  
  #respond_to :js, :html
  def new
    @message = Message.new
  end

  def create
    @task = Task.find(params[:message][:task_id])
    @message = @task.messages.create(messages_params)

    teacher = @task.job.assignment.term.course.teacher
    student = @task.student.user
    if teacher.id == @message.user_id
      addressee = student
    else
      addressee = teacher
    end
    Notification.new_event(user: addressee, task: @task, event_type: :added_message, event_time: @message.created_at)
    $redis.publish('messages.create', @message.to_json)
  end

  def events 
    response.headers["Content-Type"] = "text/event-stream"
    start = Time.zone.now
    redis = Redis.new(:host => "0.0.0.0", :port => 3000)
    redis.subscribe('messages.create') do |on|
      on.message do |event, data|
        response.stream.write("data: #{data}\n\n")
      end
    end
  rescue IOError
    logger.info "Stream closed"
  ensure
    redis.quit
    response.stream.close
  end

  private
  def messages_params
    params.require(:message).permit(:text, :user_id, :task_id)
  end
end
