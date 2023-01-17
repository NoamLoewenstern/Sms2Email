export interface UserMessage {
  sender: string;
  text: string;
  createdAt: string;
}
export interface UserDocumnet {
  email: string;
  displayName: string;
  messages?: UserMessage[];
}
