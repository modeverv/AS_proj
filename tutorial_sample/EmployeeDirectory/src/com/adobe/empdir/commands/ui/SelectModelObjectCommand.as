package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.DetailContentUIModel;
	import com.adobe.empdir.MainContentUIModel;
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.commands.data.PopulateDepartmentCommand;
	import com.adobe.empdir.commands.data.PopulateEmployeeCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.model.ConferenceRoom;
	import com.adobe.empdir.model.Department;
	import com.adobe.empdir.model.Employee;
	import com.adobe.empdir.model.IModelObject;
	
	/**
	 * This command selects a given model object in the UI, managing UI and model state.
	 */ 
	public class SelectModelObjectCommand extends Command
	{
		private var modelObject : IModelObject;
		
		private var uiModel : MainContentUIModel;
		private var detailUIModel : DetailContentUIModel;
		private var appModel : ApplicationModel
		/**
		 * Constructor
		 */ 
		public function SelectModelObjectCommand( modelObject:IModelObject ) 
		{
			this.modelObject = modelObject;
		}
		
		override public function execute() : void
		{
			uiModel = MainContentUIModel.getInstance();
			detailUIModel = DetailContentUIModel.getInstance();
			appModel = ApplicationModel.getInstance();
		
			if ( modelObject == null )
			{
				uiModel.currentState = MainContentUIModel.DEFAULT_VIEW;
				appModel.selectedItem = null;
				
				finish();
			}
			else 
			{
				var cmd : Command;
				if ( modelObject is Employee )
				{					
					cmd = new PopulateEmployeeCommand( modelObject as Employee );
					cmd.addEventListener( CommandCompleteEvent.COMPLETE, onPopulateEmployee );
					cmd.execute();
				}
				else if ( modelObject is Department )
				{
					cmd = new PopulateDepartmentCommand( modelObject as Department );
					cmd.addEventListener( CommandCompleteEvent.COMPLETE, onPopulateDepartment );
					cmd.execute();
				}
				else if ( modelObject is ConferenceRoom )
				{
					if ( detailUIModel.currentState != DetailContentUIModel.AVAILABILITY_VIEW )
						detailUIModel.currentState = DetailContentUIModel.DEFAULT_VIEW;
						
					uiModel.currentState = MainContentUIModel.CONFERENCEROOM_VIEW;
					appModel.selectedItem = modelObject;
					finish();
				}

			}	
		}
		

		private function onPopulateEmployee( evt:CommandCompleteEvent ) : void
		{
			evt.command.removeEventListener( CommandCompleteEvent.COMPLETE, onPopulateEmployee );
			
			var emp : Employee = modelObject as Employee;
			
			if ( detailUIModel.currentState == DetailContentUIModel.DIRECTREPORT_VIEW && (emp.directReports == null || emp.directReports.length == 0 ) )
			{
				detailUIModel.currentState = DetailContentUIModel.DEFAULT_VIEW;
			}

			uiModel.currentState = MainContentUIModel.EMPLOYEE_VIEW;
			appModel.selectedItem = emp;
			
			finish();
		}
		
		private function onPopulateDepartment( evt:CommandCompleteEvent ) : void
		{
			evt.command.removeEventListener( CommandCompleteEvent.COMPLETE, onPopulateDepartment );
				
			uiModel.currentState = MainContentUIModel.DEPARTMENT_VIEW;
			detailUIModel.currentState = DetailContentUIModel.DEFAULT_VIEW;
			appModel.selectedItem = modelObject;
			
			finish();
		}
		
		
		private function finish() : void
		{
			var cmd : RecordHistoryCommand = new RecordHistoryCommand();
			cmd.execute();
			notifyComplete();
		}
		
	}
}