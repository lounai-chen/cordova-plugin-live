import { NgModule } from '@angular/core';
import { IonicPageModule } from 'ionic-angular';
import { ComponentsModule } from '../../components/components.module';
import { MemberPage } from './member';


@NgModule({
    declarations: [MemberPage],
  imports: [IonicPageModule.forChild(MemberPage), ComponentsModule]
})
export class MemberPageModule {

}

