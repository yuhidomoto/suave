class ChatsController < ApplicationController
	before_action :authenticate_user!, except: [:index]

	def index
		@rooms = Room.where.not(name: nil)
		@room = Room.new
	end

	def show
		@user = User.find(params[:id])
		rooms = current_user.user_rooms.pluck(:room_id)
		user_room = UserRoom.find_by(user_id: @user.id, room_id: rooms)
		if user_room.nil?
			@room =Room.new
			@room.save
			UserRoom.create(user_id: current_user.id, room_id: @room.id)
    		UserRoom.create(user_id: @user.id, room_id: @room.id)
    	else
			@room = user_room.room
		end
		@chats = @room.chats
	end

	def create
		@room = Room.new(room_params)
		@room.user_id = current_user.id
		if @room.save
			flash[:notice] = "ルームを作成しました"
				redirect_to talk_room_chats_path(@room)
		else
			@rooms = Room.where.not(name: nil)
			flash[:notice] = "ルーム名を入力してください"
			render 'index'
		end
	end

	def update
		@room = Room.find(params[:id])
		if @room.update(room_params)
			flash[:notice] = "編集が完了しました"
			redirect_to talk_room_chats_path(@room)
		else
			@chats = @room.chats
			flash[:danger] = "ルーム名を入力してください"
			redirect_to talk_room_chats_path(@room)
		end
	end

	def destroy
		@room = Room.find(params[:id])
		@room.destroy
		flash[:notice] = "ルームを削除しました"
		redirect_to root_path
	end

	def chat_destroy
		chat = Chat.find(params[:chat_id])
		chat.destroy
		flash[:notice] = "１件のチャットを削除しました"
		redirect_to request.referer
	end

	def talk_room
		@room = Room.find(params[:id])
		rooms = current_user.user_rooms.pluck(:room_id)
		user_room = UserRoom.find_by(user_id: current_user.id, room_id: rooms)
		if user_room.nil?
			UserRoom.create(user_id: current_user.id, room_id: @room.id)
		end
		@chats = @room.chats
	end

	private
	def room_params
		params.require(:room).permit(:name, :introduction, :user_id)
	end
end
